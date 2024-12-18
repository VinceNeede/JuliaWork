using StaticArrays

mutable struct bound
    data::Int
end

struct workspace{ElT,N}
    storage :: MVector{N, ElT}
    free :: Vector{Tuple{Int,Int}}
    sizes :: Vector{Int}
    function workspace{ElT,N}() where {ElT,N}
        return new{ElT,N}(MVector{N, ElT}(undef), [(1,N)],[N])
    end
end

function free_size(work::workspace)
    return sum(work.sizes)
end
function find_free_size(work::workspace, size::Int)
    diff = work.sizes .- size
    maxa = maximum(diff)
    if maxa < 0
        return nothing
    end
    loc = findmin(x -> x<0 ? maxa+1 : x, diff)[2]
    return loc
end

global work

function set_workspace(ElT,N)
    global work = workspace{ElT,N}()
end

function malloc(size :: Int)
    global work
    i = find_free_size(work, size)
    if i === nothing
        throw(ArgumentError("No free space available"))
    end
    loc = work.free[i]
    if work.sizes[i] == size
        splice!(work.free, i)
        splice!(work.sizes, i)
    else
        work.free[i] = (loc[1]+size, loc[2])
        work.sizes[i] -= size
    end
    return (@view work.storage[loc[1]:loc[1]+size-1]), bound(loc[1]), bound(loc[1]+size-1)
end

function free!(lbound :: bound, rbound :: bound)
    global work
    i = findfirst(x -> x[1] >= lbound.data, work.free)
    if rbound.data < work.free[i][1] - 1 && (i>1 ? lbound.data > work.free[i-1][2]+1 : true)
        insert!(work.free, i, (lbound.data, rbound.data))
        insert!(work.sizes, i, rbound.data - lbound.data + 1)
    elseif rbound.data >= work.free[i][1] - 1
        work.free[i] = (lbound.data, work.free[i][2])
        work.sizes[i] = work.free[i][2] - lbound.data + 1
    elseif i>1 && lbound.data <= work.free[i-1][2]+1
        work.free[i-1] = (work.free[i-1][1], rbound.data)
        work.sizes[i-1] = rbound.data - work.free[i-1][1] + 1
    else
        throw(ArgumentError("Invalid free! call")) 
    end
end

