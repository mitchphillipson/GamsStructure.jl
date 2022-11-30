struct GamsParameter
    sets::Vector{GamsSet}
    value::DenseAxisArray
    description::String
    GamsParameter(s::GamsSet;description = "") = new([s],DenseAxisArray(zeros(length(s)),s),description)
    GamsParameter(s::Vector{GamsSet};description = "") = new(s,DenseAxisArray(zeros(length.(s)...),s...),description)
    GamsParameter(s,v,d) = new(s,v,d)
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