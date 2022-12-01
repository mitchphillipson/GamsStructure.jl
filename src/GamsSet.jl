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



"""
    GamsSet(base_path::String,set_name::Symbol;description = "",csv_description = true))

Load a GamsSet from a CSV file at location base_path/set_name.csv. 
"""
function GamsSet(base_path::String,set_name::Symbol;description = "",csv_description = true)
    F = CSV.File("$base_path/$set_name.csv",stringtype=String,silencewarnings=true)
	
    if csv_description
        cols = propertynames(F)[1:end-1]
    else
        cols = propertynames(F)
    end
    out = []
    for row in F
        if length(cols) ∈ [0,1]
            element = row[1]
        else
            element = Tuple([row[c] for c in cols])
        end
        desc = ""
        if csv_description && length(cols)!=0
            desc = row[end]
        end
        push!(out,GamsElement(element,desc))
    end

    return GamsSet(out,description)    
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



macro GamsSets(sets,base_path,block)
    sets = esc(sets)
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
            push!(code.args,:($sets[$set_name] = GamsSet(
                                $base_path,
                                $set_name,
                                description = $desc,
                                csv_description = $csv_desc)
                            )
            )
        end
    end
    return code
end

macro GamsDomainSets(sets,base_path,block)
    sets = esc(sets)
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
            push!(code.args,:($sets[$var] =  GamsDomainSet(
                                    $base_path,
                                    $parm,
                                    $col,
                                    description = $desc    
            )))
        end
    end
    return code

end