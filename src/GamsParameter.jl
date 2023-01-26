
"""
    GamsParameter(base_path::String,parm_name::Symbol,sets,GU::GamsUniverse;description = "",columns = missing)

Load a GamsParameter from a file. 
"""

function GamsParameter(base_path::String,parm_name::Symbol,sets::Tuple{Vararg{Symbol}},GU::GamsUniverse;description = "")
    df = CSV.File("$base_path/$parm_name.csv",stringtype=String,silencewarnings=true)
    s = [GU[c] for c in sets]
    out = GamsParameter(GU,sets,description = description)

    for row in df
        elm = [[Symbol(row[c])] for c in sets]
        if all([elm[i][1]∈s[i] for i=1:length(s)]) #Ensure the labels to be loaded are actually in the domain
            out[elm...] = row[:value]
        end
    end

    #This doesn't work. There could be mulitple columns, and you're picking out by name
    #out = GamsParameter(base_path,parm_name,sets,GU,collect(1:length(sets)),description = description)

    return out
end

"""
    GamsParameter(base_path::String,parm_name::Symbol,sets,GU::GamsUniverse;description = "",columns = missing)

Load a GamsParameter from a file. The columns vector is the specific columns to extract from the document. This is 
primarily useful when the column names of a file either don't match the sets or repeat. 

The value column is assumed to be at the end and should not be included in the columns argument. 
"""
function GamsParameter(base_path::String,parm_name::Symbol,sets::Tuple{Vararg{Symbol}},GU::GamsUniverse,columns::Vector{Int};description = "")
    if length(sets)!=length(columns)
        throw(DommainError("sets $sets must be the same length as columns $columns"))
    end

    df = CSV.File("$base_path/$parm_name.csv",stringtype=String,silencewarnings=true)
    s = [GU[c] for c in sets]
    out = GamsParameter(GU,sets,description = description)

    for row in df
        elm = [[Symbol(row[c])] for c in columns]
        if all([elm[i][1]∈s[i] for i=1:length(s)])
            out[elm...] = row[:value]
        end
    end

    return out
end

macro GamsParameters(GU,block)
    GU = esc(GU)
    if !(isa(block,Expr) && block.head == :block)
        error()
    end

    code = quote end
    for it in block.args
        if isexpr(it,:tuple)
            parm_name = it.args[1]
            sets = it.args[2]
            desc = ""
            if length(it.args) >= 3
                desc = it.args[3]
            end
            push!(code.args,:($add_parameter($GU,$parm_name, GamsParameter($GU,$sets,description = $desc))))
        end
    end
    return code
end


macro GamsParameters(GU,base_path,block)
    GU = esc(GU)
    base_path = esc(base_path)
    if !(isa(block,Expr) && block.head == :block)
        error()
    end

    code = quote end
    for it in block.args
        if isexpr(it,:tuple)
            parm_name = it.args[1]
            sets = it.args[2]
            desc = ""
            if length(it.args) >= 3
                desc = it.args[3]
            end
            #columns = collect(1:length(sets))
            if length(it.args) >= 4
                columns = it.args[4]
            
                push!(code.args,:($add_parameter($GU,$parm_name, 
                                GamsParameter($base_path,$parm_name,$sets,$GU,$columns,description = $desc))))
            else
                push!(code.args,:($add_parameter($GU,$parm_name, 
                                    GamsParameter($base_path,$parm_name,$sets,$GU,description = $desc))))
            end
        end
    end
    return code
end


function _convert_idx(P::GamsParameter,i::Int,idx::Colon)
    GU = P.universe
    set = GU[P.sets[i]]
    return _convert_idx(P,i,[e for e in set])
end


function _convert_idx(P::GamsParameter,i::Int,idx::Symbol)
    s = P.sets[i]
    GU = P.universe
    set = GU[s]
    @assert (idx == s || idx∈set.aliases) "Index $idx at location $i does not match parameter domain $s or an alias $(set.aliases)"

    return _convert_idx(P,i,[e for e in set])
end

function _convert_idx(P::GamsParameter,i::Int,idx::Vector{Symbol})
    set_index = P.universe[P.sets[i]].index
    set = [set_index[e] for e in idx]
    #indexin(idx,[e for e in GU[P.sets[i]]])#findall(x-> x∈idx, GU[P.sets[i]])
    if length(set) == 1
        return set[1]
    end
    return set
end

function _convert_idx(P::GamsParameter,i::Int,idx::Vector{Bool})
    #GU = P.universe
    #set = P.sets[i]
    return idx
end

function _convert_idx(P::GamsParameter,i::Int,idx::GamsSet)
    return _convert_idx(P,i,[e for e in idx])
end

function _convert_idx(P::GamsParameter,i::Int,idx)
    return idx
end

function Base.getindex(P::GamsParameter,idx...)
    idx = map(x->_convert_idx(P,x[1],x[2]),enumerate(idx))
    return P.value[idx...]
end


function Base.iterate(iter::GamsParameter)
    next = iterate(iter.value)
    return next === nothing ? nothing : (next[1], next[2])
end

function Base.iterate(iter::GamsParameter, state)
    next = iterate(iter.value, state)
    return next === nothing ? nothing : (next[1], next[2])
end


function Base.setindex!(X::GamsParameter,value,idx...)
    new_index = map(x->_convert_idx(X,x[1],x[2]),enumerate(idx))
    X.value[new_index...] = value
end

function Base.length(X::GamsParameter)
    return length(X.value)
end


function Base.show(io::IO,P::GamsParameter)
    print("Description: $(P.description)\nDomain: $(P.sets)\n\n")
    show(P.value)
end


#function Base.:*(P::GamsParameter,x)
#    return P.value*x
#end

#function Base.:*(x,P::GamsParameter)
#    return P.value*x
#end