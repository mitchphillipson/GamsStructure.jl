struct GamsParameter
    sets::Vector{GamsSet}
    value::DenseAxisArray
    description::String
    GamsParameter(s::GamsSet;description = "") = new([s],DenseAxisArray(zeros(length(s)),s),description)
    GamsParameter(s::Vector{GamsSet};description = "") = new(s,DenseAxisArray(zeros(length.(s)...),s...),description)
    GamsParameter(s::Vector{GamsSet},v::DenseAxisArray,d::String) = new(s,v,d)
end



function GamsParameter(base_path::String,parm_name::Symbol,columns::Vector,sets;description = "")

    return GamsParameter(base_path,parm_name,columns[1],sets,description = columns[2])

end

function GamsParameter(base_path::String,parm_name::Symbol,columns,sets;description = "")

    df = CSV.File("$base_path/$parm_name.csv",stringtype=String,silencewarnings=true)
    s = [sets[c] for c in columns]
    out = GamsParameter(s,description = description)
    #DenseAxisArray(zeros(length.(s)...),s...)

    for row in df
        out[Symbol.([row[c] for c in columns])...] = row[:value]
    end

    return out
end



function GamsParameter(columns::Vector,sets;initial_value = zeros)
    sets = [sets[c] for c in columns[1]]
    return GamsParameter(sets,description = columns[2])
end

function GamsParameter(columns,sets; description = "",initial_value = zeros)
    sets = [sets[c] for c in columns]
    return GamsParameter(sets,description = description)
end

macro GamsParameters(parm_dict,sets,block)
    parm_dict = esc(parm_dict)
    sets = esc(sets)
    if !(isa(block,Expr) && block.head == :block)
        error()
    end

    code = quote end
    for it in block.args
        if isexpr(it,:tuple)
            parm_name = it.args[1]
            columns = it.args[2]
            desc = ""
            if length(it.args) >= 3
                desc = it.args[3]
            end
            push!(code.args,:($parm_dict[$parm_name] = GamsParameter($columns,$sets,description = $desc)))
        end
    end
    return code
end


macro GamsParameters(parm_dict,sets,base_path,block)
    parm_dict = esc(parm_dict)
    sets = esc(sets)
    base_path = esc(base_path)
    if !(isa(block,Expr) && block.head == :block)
        error()
    end

    code = quote end
    for it in block.args
        if isexpr(it,:tuple)
            parm_name = it.args[1]
            columns = it.args[2]
            desc = ""
            if length(it.args) >= 3
                desc = it.args[3]
            end
            push!(code.args,:($parm_dict[$parm_name] = GamsParameter($base_path,$parm_name,$columns,$sets,description = $desc)))
        end
    end
    return code
end




function _convert_idx(idx)
    return idx
end

function _convert_idx(idx::GamsSet)
    return [e for e in idx]
end

function Base.getindex(X::GamsParameter,idx...)
    new_index = _convert_idx.(idx)
    return X.value[new_index...]
end

function Base.setindex!(X::GamsParameter,value,idx...)
    new_index = _convert_idx.(idx)
    X.value[new_index...] = value
end

function Base.length(X::GamsParameter)
    return length(X.value)
end

function Base.:*(X::GamsParameter,y)
    return GamsParameter(X.sets,X.value*y,X.description)
end

function Base.:*(x,Y::GamsParameter)
    return Y*x
end

function Base.iterate(iter::GamsParameter)
    next = iterate(iter.value)
    return next === nothing ? nothing : (next[1], next[2])
end

function Base.iterate(iter::GamsParameter, state)
    next = iterate(iter.value, state)
    return next === nothing ? nothing : (next[1], next[2])
end