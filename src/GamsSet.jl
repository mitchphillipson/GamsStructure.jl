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
    GamsSet(base_path::String,set_name::Symbol;description = "",csv_description = true))

Load a GamsSet from a CSV file at location base_path/set_name.csv. 

Sets must be one dimensional (at least for now) and it's assumed the first column are the elements
and the second column is the description. If the second column is missing, the description is ""

Note: csv_description currently does nothing. 
"""
function GamsSet(base_path::String,set_name::Symbol;description = "",csv_description = true,aliases = [])
    F = CSV.File("$base_path/$set_name.csv",stringtype=String,silencewarnings=true)
	
    out = []
    cols = propertynames(F)
    for row in F
        element = row[1]
        desc = ""
        if length(cols)==2 && !(ismissing(row[2]))
            desc = row[2]
        end
        push!(out,GamsElement(element,desc))
    end

    return GamsSet(out,description,aliases)    
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


function GamsSet(base_path::String,set_info::Vector)
    if length(set_info) == 1
        return GamsSet(base_path,set_info[1])
    elseif length(set_info) == 2
        return GamsSet(base_path,set_info[1],description = set_info[2])
    elseif length(set_info) == 3
        return GamsSet(base_path,set_info[1],description = set_info[2],csv_description = set_info[3])
    end
    #return GamsSet(base_path,set_info...)
end


_active_elements(S::GamsSet) = [e for e in S.elements if e.active]


Base.iterate(S::GamsSet,state = 1) = state> length(S) ? nothing : (_active_elements(S)[state].name,state+1)

Base.keys(S::GamsSet) = [e for e in S]

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
    return length(_active_elements(X))
end


"""
    @GamsSet(GU,set_name,description,block)

Macro to create a GamsSet. 

```
@GamsSet(GU,:i,"example set",begin
    element_1, "Description 1"
    element_2, "Description 2"
    element_3, "Description 3"
end)
```
"""
macro GamsSet(GU,set_name,description,block)
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

"""
    @GamsSets(GU,base_path,block)

Load a collection of sets from a file. This will search for 
the file `base_path\\name.csv` where name is the first
entry of each line in the block.

@GamsSets(GU,"sets",begin
    :i, "Set 1"
    :j, "Set 2"
end)
"""
macro GamsSets(GU,base_path,block)
    GU = esc(GU)
    base_path = esc(base_path)
    if !(isa(block,Expr) && block.head == :block)
        error("Problem")
    end
    code = quote end
    for it in block.args
        if isexpr(it, :tuple)
            set_name = it.args[1]
            desc = ""
            if length(it.args)>=2
                desc = it.args[2]
            end
            csv_desc = true
            if length(it.args)>=3
                csv_desc = it.args[3]
            end
            push!(code.args,:($add_set($GU,$set_name, GamsSet(
                                $base_path,
                                $set_name,
                                description = $desc,
                                csv_description = $csv_desc)
                            ))
            )
        end
    end
    return code
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



