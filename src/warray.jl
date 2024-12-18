

abstract type WAbstractArray end
mutable struct Allocated
    data :: Bool
end
Base.getindex(arr::WAbstractArray, inds::Int...) = arr.data[inds...]
Base.getindex(arr::WAbstractArray, range::UnitRange{Int}) = arr.data[range]
Base.getindex(arr::WAbstractArray, cart::CartesianIndex) = arr.data[cart]

Base.setindex!(arr::WAbstractArray, value, inds::Int...) = (arr.data[inds...] = value)
Base.setindex!(arr::WAbstractArray, values::Vector, range::UnitRange{Int}) = arr.data[range] = values
Base.size(arr::WAbstractArray) = size(arr.data)
Base.length(arr::WAbstractArray) = length(arr.data)
Base.eltype(arr::WAbstractArray) = eltype(arr.data)

function Base.similar(arr::WAbstractArray)
    return WArray(size(arr))
end

struct WArray{N} <: WAbstractArray
    data :: AbstractArray{Float64,N}
    lbound :: bound
    rbound :: bound
    isallocated :: Allocated
end

function WArray(dims :: Tuple{Vararg{Int}})
    size = prod(dims)
    arr, lbound, rbound = malloc(size)
    return WArray{length(dims)}(reshape(arr, dims), lbound, rbound, Allocated(true))
end

function free!(arr :: WAbstractArray)
    if arr.isallocated.data
        free!(arr.lbound, arr.rbound)
        arr.isallocated.data = false
    end
end

const WVector = WArray{1}

function WVector(size :: Int)
    arr, lbound, rbound = malloc(size)
    return WArray{1}(reshape(arr, size), lbound, rbound, Allocated(true))
end

const WMatrix = WArray{2}

function WMatrix(rows :: Int, cols :: Int)
    arr, lbound, rbound = malloc(rows*cols)
    return WArray{2}(reshape(arr, rows, cols), lbound, rbound, Allocated(true))
end

fill!(arr::WAbstractArray, value) = Base.fill!(arr.data, value)
function fill(size::Tuple{Vararg{Int}}, value)
    res = WArray(size)
    fill!(res, value)
    return res
end