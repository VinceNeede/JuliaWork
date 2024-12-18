module JuliaWork
    include("workspace.jl")
    include("warray.jl")
    include("warray_operations.jl")
    include("warray_algebra.jl")

    # Dynamically export all functions and variables except eval and include
    for name in names(JuliaWork, all=true)
        if !startswith(string(name), "_") && !(name in [:eval, :include])
            @eval export $name
        end
    end
end