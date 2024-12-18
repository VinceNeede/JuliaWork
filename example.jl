push!(LOAD_PATH, "src")
using JuliaWork

set_workspace(Float64, 1000)
a = JuliaWork.fill((10,), 100)
b = JuliaWork.fill((10,), 200)
c = a + b
println(c)
