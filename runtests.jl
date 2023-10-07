using Test
include("SymRegMethods.jl")
using .SymRegMethods

@testset "SymRegMethods Tests" begin
    println(random_expression())
end