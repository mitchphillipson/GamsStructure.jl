"""
    GamsSet(x::Tuple...;description = "")

GamsSet constructor for a tuple of the form (name,description) which
will be made into GamsElements
"""
function GamsSet(x::Tuple...;description = "")
    return GamsSet([GamsElement(a,b) for (a,b) in x],description)
end

"""
    GamsSet(x::Vector{Tuple{Symbol,String}};description = "")

GamsSet constructor for a vector of tuples of the form (name,description) which
will be made into GamsElements
"""
function GamsSet(x::Vector{Tuple{Symbol,String}};description = "")
    return GamsSet([GamsElement(a,b) for (a,b) in x],description)
end

"""
    GamsSet(e::Vector{Symbol};description = "")   

GamsSet constructor for a tuple of symbols which
will be made into GamsElements with empty description.
"""
function GamsSet(e::Vector{Symbol};description = "")   
    return GamsSet([GamsElement(i,"") for i∈e],description)
end

"""
    GamsDomainSet(base_path::String,set_info::Tuple;description = "")

Load data from a single column of a CSV into a GamsSet.

The variable set_info is a tuple of the form (Symbol,Int) where the Int
is the column to load.

#Should be modified to be separate inputs.
"""
function GamsDomainSet(base_path::String,parm_name::Symbol,column::Int;description = "")
    F = CSV.File("$base_path/$(parm_name).csv",stringtype=String,silencewarnings=true)
    
    elements = unique([row[column] for row in F])
    out = [GamsElement(e) for e in elements]
    return GamsSet(out,description)
end

"""
    deactivate(GU::GamsUniverse,s::Symbol,elements...)

Deactivate the given elements from the set.
"""
function deactivate(GU::GamsUniverse,s::Symbol,elements...)
    N = 0
    for elm in elements
        if GU[s][elm].active
            GU[s][elm].active = false
            N+=1
        end
    end
    GU[s].length += -N
end

"""
    activate(GU::GamsUniverse,s::Symbol,elements...)

Activate the given elements from the set.
"""
function activate(GU::GamsUniverse,s::Symbol,elements...)
    N = 0
    for elm in elements
        if !GU[s][elm].active
            GU[s][elm].active = true
            N+=1
        end
    end
    GU[s].length += N

end

function Base.iterate(S::GamsSet, state=1)
    if state > length(S.elements) 
        return nothing
    end

    for i∈state:length(S.elements)
        if S.elements[i].active
            return (S.elements[i].name,i+1)
        end
    end
    return nothing


end


Base.keys(S::GamsSet) = [e for e in S]

function Base.show(io::IO, x::GamsSet)
    if x.description != ""
        print(io,"$(x.description)\n\n")
    end
    for elm in [e for e in x.elements if e.active]
        println(io,elm)
    end
end

function Base.in(x::Symbol,r::GamsSet)  
    return x∈keys(r.index)
end # = (x in [e for e in r])
@inline Base.in(x::GamsElement,r::GamsSet) = (x.name in r)


function Base.getindex(X::GamsSet,i::Int)
    return X.elements[i]
end


function Base.getindex(X::GamsSet,i::Symbol)
    try
        return X[X.index[i]]
    catch
        error("$i is not a member of this set")
    end
end

function Base.getindex(X::GamsSet,i::GamsSet)

    return GamsSet([e for e in X.elements if e in i])
end

function Base.lastindex(X::GamsSet)
    elm = X.elements[end]
    out = elm.name
    return out
end

function Base.firstindex(X::GamsSet)
    elm = X.elements[begin]
    out = elm.name
    return out
end


function Base.setindex!(X::GamsSet,active::Bool,i)
    X[i].active = active
end

function Base.length(X::GamsSet)
    return X.length#length(X.elements)
    #return length(_active_elements(X))
end


"""
    @create_set!(GU,set_name,description,block)

Macro to create a GamsSet. 

```
@create_set!(GU,:i,"example set",begin
    element_1, "Description 1"
    element_2, "Description 2"
    element_3, "Description 3"
end)
```
"""
macro create_set!(GU,set_name,description,block)
    GU = esc(GU)
    set_name = esc(set_name)
    description = esc(description)
    if !(isa(block,Expr) && block.head == :block)
        error("Problem")
    end
    elements = []
    for it in block.args
        if isexpr(it,:tuple)
            elm = it.args[1]
            desc = ""
            if length(it.args)>=2
                desc = it.args[2]
            end
            push!(elements,GamsElement(elm,desc))
        end
    end

    return :(add_set($GU,$set_name,GamsSet($elements,$description)))
end



macro GamsDomainSets(GU,base_path,block)
    GU = esc(GU)
    base_path = esc(base_path)
    if !(isa(block,Expr) && block.head == :block)
        error("Problem")
    end
    code = quote end
    for it in block.args
        if isexpr(it, :tuple)
            var = it.args[1]
            parm = it.args[2]
            col = it.args[3]
            desc = ""
            if length(it.args)>=4
                desc = it.args[4]
            end
            push!(code.args,:($add_set($GU,$var,  GamsDomainSet(
                                    $base_path,
                                    $parm,
                                    $col,
                                    description = $desc    
            ))))
        end
    end
    return code

end



