module GamsStructure

using CSV

using JuMP.Containers
using CSV
using MacroTools
using JSON
using DelimitedFiles

export GamsElement, GamsSet, GamsParameter, @GamsSets,
        @GamsParameters,@GamsDomainSets,GamsDomainSet,
        GamsUniverse,add_set,add_parameter,alias,GamsScalar,
        @GamsScalars,add_scalar,scalar,unload,load_universe,
        load_universe!,@GamsSet




        
include("structs.jl")
include("GamsUniverse.jl")
include("GamsSet.jl")
include("GamsParameter.jl")
include("GamsScalar.jl")

include("io/unload.jl")
include("io/load.jl")

end # module GamsStructure
