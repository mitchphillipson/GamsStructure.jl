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
    GamsSet(e,description = "") = new(e,description)
end



struct GamsParameter
    universe
    sets::Tuple{Symbol,Vararg{Symbol}}
    value::DenseAxisArray
    description::String
    GamsParameter(GU,set_name::Symbol,set::GamsSet;description = "") = new(GU,(set_name,),DenseAxisArray(zeros(length(set)),set),description)
    GamsParameter(GU,set_names::Tuple{Symbol,Vararg{Symbol}},sets::Vector{GamsSet};description = "") = new(GU,set_names,DenseAxisArray(zeros(length.(sets)...),sets...),description)
    GamsParameter(GU,s::Tuple{Symbol,Vararg{Symbol}},v::DenseAxisArray,d::String) = new(GU,s,v,d)
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




