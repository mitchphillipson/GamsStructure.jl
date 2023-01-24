"""
    GamsElement(Name, Description, active = true)

A base struct for GamsSets. Each Name will be converted to a symbol. 
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
"""
struct GamsSet
    elements::Vector{GamsElement}
    description::String
    index::Dict{Symbol,Int}
    aliases::Vector{Symbol}
    GamsSet(e,description = "") = new(e,description,Dict(b=>a for (a,b) in enumerate([i.name for i in e])),[])
end



struct GamsParameter{N}
    universe
    sets::Tuple{Vararg{Symbol}}
    value::Array{Float64,N}
    description::String
    GamsParameter(GU,sets::Tuple{Vararg{Symbol}},description::String) = new{length(sets)}(GU,sets,zeros(Float64,Tuple(length(GU[e].elements) for e∈sets)),description)
    GamsParameter(GU,sets::Tuple{Vararg{Symbol}};description = "") = new{length(sets)}(GU,sets,zeros(Float64,Tuple(length(GU[e].elements) for e∈sets)),description)
end


mutable struct GamsScalar
    scalar::Number
    description::String
    GamsScalar(scalar::Number;description = "") = new(scalar,description)
end

struct GamsUniverse
    sets::Dict{Symbol,GamsSet}
    parameters::Dict{Symbol,GamsParameter}
    scalars::Dict{Symbol,GamsScalar}
    GamsUniverse() = new(Dict(),Dict(),Dict())
end



function Base.show(io::IO,x::GamsElement)
    if x.description != ""
        print("$(x.name) \t \"$(x.description)\"")
    else
        print("$(x.name)")
    end
end



function set_scalar!(s::GamsScalar,scalar::Number)
    s.scalar = scalar
end

function scalar(s::GamsScalar)
    return s.scalar
end




