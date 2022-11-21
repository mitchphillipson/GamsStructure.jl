module GamsStructure

#using CSV

using JuMP.Containers

export GamsElement, GamsSet, GamsParameter


include("GamsSet.jl")
include("GamsParameter.jl")


end # module GamsStructure
