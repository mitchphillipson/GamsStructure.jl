module GamsStructure

using CSV

using CSV
using MacroTools
using JSON
using DelimitedFiles

using HDF5

export GamsElement


export GamsSet, alias,@create_set!,@GamsDomainSets,GamsDomainSet,
        load_set,load_set!,@load_sets!,deactivate,activate,
        @set

export  Parameter,@parameter,@parameters,
        load_parameter,load_parameter!,@load_parameters!,domain

export Mask

export GamsUniverse,add_set,add_parameter,unload,load_universe,
        load_universe!,sets,parameters
        

export @extract_sets_as_vector,@extract, @alias


#GamsScalar,
#        @GamsScalars
#add_scalar,scalar,



        
include("structs.jl")
include("dense_sparse.jl")
include("parameter.jl")
include("GamsUniverse.jl")
include("GamsSet.jl")
#include("GamsParameter.jl")
#include("GamsScalar.jl")

include("macros.jl")

include("io/unload.jl")
include("io/load.jl")
include("io/macros.jl")

end # module GamsStructure
