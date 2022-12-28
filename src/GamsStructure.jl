module GamsStructure

#using CSV

using JuMP.Containers
using CSV
using MacroTools


export GamsElement, GamsSet, GamsParameter, @GamsSets,
        @GamsParameters,@GamsDomainSets,GamsDomainSet,
        GamsUniverse,add_set,add_parameter,alias,GamsScalar,
        @GamsScalars,add_scalar,scalar




        
include("structs.jl")
include("GamsUniverse.jl")
include("GamsSet.jl")
include("GamsParameter.jl")
include("GamsScalar.jl")


end # module GamsStructure
