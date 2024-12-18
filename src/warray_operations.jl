
# view behaviour
struct WSubArray{P,N} <: WAbstractArray{N}
    parent :: P
    range :: Tuple{Vararg{UnitRange{Int}}}
    data :: AbstractArray
end

function Base.view(arr::WAbstractArray, range::UnitRange{Int}...)
    return WSubArray(arr, range, Base.view(arr.data, range...))
end


struct WReshaped{P,N} <: WAbstractArray{N}
    parent :: P
    dims :: Tuple{Vararg{Int}}
    data :: AbstractArray
end

function Base.reshape(arr::WAbstractArray, dims::Tuple{Vararg{Int}})
    return WReshaped(arr,dims,Base.reshape(arr.data, dims))
end

function Base.permutedims!(dest::WAbstractArray, src::WAbstractArray, perm::Vector{Int})
    Base.permutedims!(dest.data, src.data, perm)
end


