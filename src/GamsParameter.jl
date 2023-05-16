

"""
    domain(P::GamsParameter)

Return the domain of the paramter P in the form of a vector of
symbols.
"""
function domain(P::GamsParameter)
    return P.sets
end

""" 
    @create_parameters(GU,block)

Create many empty parameters

```
@create_parameters(GU,begin
    :P, (:set_1,:set_2), "Description 1"
    :X, (:set_1,), "Description 2"
end)
```
"""
macro create_parameters(GU,block)
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





@inline _convert_idx(idx::Symbol,S::GamsSet,GU::GamsUniverse) = [S.index[i] for i∈GU[idx]]
@inline _convert_idx(idx::Vector{Symbol},S::GamsSet,GU::GamsUniverse) = length(idx)==1 ? S.index[idx[1]] : [S.index[i] for i∈idx]
@inline _convert_idx(idx::GamsSet,S::GamsSet,GU::GamsUniverse) = [S.index[i] for i∈idx]
@inline _convert_idx(idx::Colon,S::GamsSet,GU::GamsUniverse) = [S.index[i] for i∈S]
@inline _convert_idx(idx,S::GamsSet,GU::GamsUniverse) = idx

"""
There are several choices for idx

    1. : -> Return the entire parameter. This isn't a recommended usage, it's better to explicit about the set
    2. Symbol -> The symbol represents a set name. Return the parameter restricted to the elments of the specified set.
    3. Vector{Symbol} -> Return the elements of the paramter corresponding to the symbols in the vector
    4. Vector{Bool} -> For masking, you'll usually have a mask defined before using this option
    5. GamsSet -> Similar to 2, except giving an explicit GamsSet rather than its symbol.
"""
function Base.getindex(P::GamsParameter,idx...)
    GU = P.universe
    sets = [GU[s] for s∈domain(P)]
    idx = map((x,S)->_convert_idx(x,S,GU),idx,sets)
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


function Base.setindex!(P::GamsParameter,value,idx...)
    GU = P.universe
    sets = [GU[s] for s∈domain(P)]
    idx = map((x,S)->_convert_idx(x,S,GU),idx,sets)
    P.value[idx...] = value
end

function Base.length(X::GamsParameter)
    return length(X.value)
end


function Base.show(io::IO,P::GamsParameter)
    d = domain(P)
    print("Description: $(P.description)\nDomain: $(d)\n\n")
    show(P.value)
end


#function Base.:*(P::GamsParameter,x)
#    return P.value*x
#end

#function Base.:*(x,P::GamsParameter)
#    return P.value*x
#end