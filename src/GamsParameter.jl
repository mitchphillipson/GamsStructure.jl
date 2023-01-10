

function GamsParameter(columns,GU::GamsUniverse; description = "",initial_value = zeros)
    sets = [GU[c] for c in columns]
    return GamsParameter(GU,columns,sets,description = description)
end


"""
    GamsParameter(base_path::String,parm_name::Symbol,sets,GU::GamsUniverse;description = "",columns = missing)

Load a GamsParameter from a file. 
"""

function GamsParameter(base_path::String,parm_name::Symbol,sets,GU::GamsUniverse;description = "")
    df = CSV.File("$base_path/$parm_name.csv",stringtype=String,silencewarnings=true)
    s = [GU[c] for c in sets]
    out = GamsParameter(sets,s,description = description)

    for row in df
        out[Symbol.([row[c] for c in sets])...] = row[:value]
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
    out = GamsParameter(GU,sets,s,description = description)

    for row in df
        out[Symbol.([row[c] for c in columns])...] = row[end]
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
            push!(code.args,:($add_parameter($GU,$parm_name, GamsParameter($sets,$GU,description = $desc))))
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

function Base.show(io::IO, parm::GamsParameter)
    out = "Domain: $(parm.sets)\n"
    if parm.description != ""
        out *= "Description: $(parm.description)\n"
    end
    out *= "\n"
    out *= string(parm.value)

    print(out)

    return out

end