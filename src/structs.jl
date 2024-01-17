"""
    GamsElement(name::union{Symbol,Tuple}, description::String="", active::Bool = true)

A base struct for GamsSets. Each Name will be converted to a symbol. 
The `active` keyword denotes if the element should appear in sets.
"""
mutable struct GamsElement
    name::Union{Symbol,Tuple}
    description::String
    active::Bool
    GamsElement(x::Tuple,y="",active=true) = new(Tuple(Symbol(e) for e in x),string(y),active)
    GamsElement(x,y="",active=true) = new(Symbol(x),string(y),active) #what if y can't be convereted to a string?
end


"""
    GamsSet(Elements::Vector{GamsElement}, description = "")

Container to hold GamsElements. 

Best way to create a new set is using the [`@set`](@ref) macro.
"""
mutable struct GamsSet
    elements::Vector{GamsElement}
    description::String
    index::Dict{Symbol,Int}
    aliases::Vector{Symbol}
    length::Int64
    GamsSet(e,description = "",aliases= []) = new(e,description,Dict(b=>a for (a,b) in enumerate([i.name for i in e])),aliases,length(e))
    #GamsSet(e,description = "",aliases= []) = new(e,description,NamedTuple(reverse.(enumerate([i.name for i∈e])))  ,aliases)
end


"""
    GamsParameter{N}(GU,sets::Tuple{Vararg{Symbol}},value::Array{Float64,N},description::String)


"""
#struct GamsParameter{N}
#    universe
#    sets::Tuple{Vararg{Symbol,N}}
#    value::Array{Float64,N}
#    description::String
#    GamsParameter(GU,sets::Tuple{Vararg{Symbol}},description::String) = new{length(sets)}(GU,sets,zeros(Float64,Tuple(length(GU[e].elements) for e∈sets)),description)
#    GamsParameter(GU,sets::Tuple{Vararg{Symbol}};description = "") = new{length(sets)}(GU,sets,zeros(Float64,Tuple(length(GU[e].elements) for e∈sets)),description)
#end


abstract type DenseSparseArray{T,N} <: AbstractArray{T,N} end

"""
    Parameter(GU,domain::Tuple{Vararg{Symbol}};description::String="") = new{Float64,length(domain)}(GU,domain,Dict{Any,Float64}(),description)


Container to hold parameters. Highly recommended to create using the [`@parameter`](@ref) macro.

Parameters can be indexed either by set name

P[:set_1,:set_2]

or by list of element names

P[[:element_1,:element_2],[:e_1,:e_2]]

or a mix of both

P[:set_1,:e_1]

Order of precedence is set then element, so if you have an element with the same symbol
as the set name, there will be a conflict. You can either wrap the element name in a 
vector or avoid this.  
"""
struct Parameter{T<:Number,N} <: DenseSparseArray{T,N}
    universe
    domain::NTuple{N,Symbol}
    data::Dict{NTuple{N,Any},T}
    description::String
    Parameter(GU,domain::Tuple{Vararg{Symbol}};description::String="") = new{Float64,length(domain)}(GU,domain,Dict{Any,Float64}(),description)
    Parameter(GU,domain::Symbol;description::String="") = new{Float64,1}(GU,tuple(domain),Dict{Any,Float64}(),description)
end

struct Mask{N} <: DenseSparseArray{Bool,N}
    universe
    domain::NTuple{N,Symbol}
    data::Dict{NTuple{N,Any},Bool}
    description::String
    Mask(GU,domain::Vararg{Symbol,N};description::String = "") where {N}= new{N}(GU,domain,Dict{Any,Bool}(),description)
end


"""
    GamsUniverse(sets::Dict{Symbol,GamsSet}
                parameters::Dict{Symbol,GamsParameter}
                scalars::Dict{Symbol,GamsScalar})

Note: scalars are going to be deprecated soon.

Access objects like an array,
```
GU[:X]
```
This will return the X object, either a set or parameter. The search
order is sets first, then parameters.

Print a universe to see it's members and their descriptions.
"""
struct GamsUniverse
    sets::Dict{Symbol,GamsSet}
    parameters::Dict{Symbol,Parameter}
    #scalars::Dict{Symbol,GamsScalar}
    GamsUniverse() = new(Dict(),Dict())
end



function Base.show(io::IO,x::GamsElement)
    if x.description != ""
        print(io,"$(x.name) \t \"$(x.description)\"")
    else
        print(io,"$(x.name)")
    end
end






