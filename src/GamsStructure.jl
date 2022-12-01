module GamsStructure

#using CSV

using JuMP.Containers
using CSV
using MacroTools


export GamsElement, GamsSet, GamsParameter, @GamsSets,
        @GamsParameters,@GamsDomainSets,GamsDomainSet


include("GamsSet.jl")
include("GamsParameter.jl")


end # module GamsStructure
