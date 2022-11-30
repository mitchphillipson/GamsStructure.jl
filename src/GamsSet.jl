"""
    GamsElement(Name, Description, active = true)

A base struct for GamsSets. Each Name will be converted to a symbol. 
"""
mutable struct GamsElement
    name::Union{Symbol,Tuple}
    description::String
    active::Bool
    GamsElement(x::Tuple,y="",active=true) = new(Tuple(Symbol(e) for e in x),String(y),active)
    GamsElement(x,y="",active=true) = new(Symbol(x),String(y),active)
end


function Base.show(io::IO,x::GamsElement)
    if x.description != ""
        print("$(x.name) \t \"$(x.description)\"")
    else
        print("$(x.name)")
    end
end

"""
    GamsSet(Elements::Vector{GamsElement}, description = "")

Container to hold GamsElements. 
"""
struct GamsSet
    elements::Vector{GamsElement}
    description::String
    GamsSet(e,d = "") = new(e,d)
end

function GamsSet(x::Tuple...;description = "")
    return GamsSet([GamsElement(a,b) for (a,b) in x],description)
end

Base.iterate(S::GamsSet,state = 1) = state> length(S.elements) ? nothing : (S.elements[state].name,state+1)


function Base.show(io::IO, x::GamsSet)
    if x.description != ""
        print("$(x.description)\n\n")
    end
    for elm in [e for e in x.elements if e.active]
        println(elm)
    end
end

function Base.in(x::Symbol,r::GamsSet)
    return x in [e for e in r]
end

function Base.in(x::GamsElement,r::GamsSet)
    return x.name in r
end


function Base.getindex(X::GamsSet,i)
    for elm in X.elements
        if elm.name == i
            return elm
        end
    end
    error("$i is not a member of this set")
end

function Base.getindex(X::GamsSet,i::GamsSet)

    return GamsSet([e for e in X.elements if e in i])
end



function Base.setindex!(X::GamsSet,active::Bool,i)
    X[i].active = active
end

function Base.length(X::GamsSet)
    return length(X.elements)
end



macro GamsSet(x)
    if !(isa(x,Expr)) && x.head == :block
        error("Problem")
    end

    #code = Expr(:tuple)
    args = []
    for it in x.args
        if isa(it, LineNumberNode)
            lastline = it
        else#if isexpr(it, :tuple)
            append!(args,Tuple(it.args))
        end
    end

    :($GamsSet($args))

    #pu


end