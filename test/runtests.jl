import Pkg
Pkg.add("Test")



using Test
using GamsStructure


@testset "GamStructure Tests" begin

    include("load_unload.jl")




end