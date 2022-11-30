module GamsStructure

#using CSV

using JuMP.Containers
using CSV


export GamsElement, GamsSet, GamsParameter, @GamsSet, csv_set, load_sets,load_sets!,
        csv_parameter, load_parameters, load_parameters!,empty_parameter, empty_parameters,
        empty_parameters!


include("GamsSet.jl")
include("GamsParameter.jl")
include("csv_load.jl")

end # module GamsStructure
