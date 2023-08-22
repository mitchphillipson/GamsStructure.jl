module GamsStructure

using CSV

using JuMP.Containers
using CSV
using MacroTools
using JSON
using DelimitedFiles

using HDF5

export GamsElement


export GamsSet, alias,@create_set!,@GamsDomainSets,GamsDomainSet,
        load_set,load_set!,@load_sets!,deactivate,activate

export  GamsParameter,@create_parameters,
        load_parameter,load_parameter!,@load_parameters!,domain

export GamsUniverse,add_set,add_parameter,unload,load_universe,
        load_universe!,sets,parameters
        

#GamsScalar,
#        @GamsScalars
#add_scalar,scalar,



        
include("structs.jl")
include("GamsUniverse.jl")
include("GamsSet.jl")
include("GamsParameter.jl")
#include("GamsScalar.jl")

include("io/unload.jl")
include("io/load.jl")
include("io/macros.jl")

end # module GamsStructure
