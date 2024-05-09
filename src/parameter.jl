

domain(P::Parameter) = P.domain
universe(P::Parameter) = P.universe
data(P::Parameter) = P.data
description(P::Parameter) = P.description



domain(P::Mask) = P.domain
universe(P::Mask) = P.universe
data(P::Mask) = P.data
description(P::Mask) = P.description

function _convert_idx(x::Mask,GU::GamsUniverse,d::Vararg{Symbol})
    @assert domain(x) == d "The domain of the mask $(domain(x)) does not match the domain $d of the parameter in the position provided"
    return keys(data(x))
end

"""

if v = [:a,:b,:c,:d,:e] and p = (2,2,1)

we expect output of 

[[:a,:b],[:c,:d],[:e]]
"""
function partition(v,p)
    ind = ((sum(p[i] for i∈1:n;init=1),sum(p[i] for i∈1:(n+1);init=1)-1) for n∈0:(length(p)-1))
    return [[v[i] for i∈a:b] for (a,b)∈ind]
end

function dimension(x)
    return 1
end

#function Base.getindex(P::Parameter{T,N},idx::Vararg{Any}) where {T,N}
#    if any(isa(x,Mask) for x∈idx)
#        _getindex_mask(P,idx...)
#    else
#        GamsStructure._getindex(P,idx...)
#    end
#end

"""
    Code from TupleTools.jl package
"""
flatten(x::Any) = (x,)
flatten(t::Tuple{}) = ()
flatten(t::Tuple) = (flatten(t[1])..., flatten(Base.tail(t))...)
flatten(x, r...) = (flatten(x)..., flatten(r)...)

function _getindex_mask(P::Parameter{T,N},idx...) where {T,N}
    
    GU = GamsStructure.universe(P)
    d = GamsStructure.domain(P)

    domain_match = GamsStructure.partition(d,GamsStructure.dimension.(idx))

    idx = map((x,d) -> GamsStructure._convert_idx(x,GU,d...), idx, domain_match) |>
        x -> GamsStructure.collect(Iterators.product(x...)) |>
        x -> GamsStructure.dropdims(x,dims=tuple(findall(size(x).==1)...)) |>
        x -> flatten.(x)


    #return idx
    data_dict = GamsStructure.data(P)
    length(idx) == 1 ? get(data_dict,idx[1],zero(T)) : get.(Ref(data_dict),idx,zero(T))

end


function Base.setindex!(P::Parameter{T,N},value, idx::Vararg{Any}) where {T,N}
    if any(isa(x,Mask) for x∈idx)
        _setindex_mask!(P,value,idx...)
    else
        _setindex!(P,value,idx...)
    end
end

function _setindex_mask!(P::Parameter{T,N},value,idx...) where {T,N}
    
    GU = GamsStructure.universe(P)
    d = GamsStructure.domain(P)

    domain_match = GamsStructure.partition(d,GamsStructure.dimension.(idx))

    idx = map((x,d) -> GamsStructure._convert_idx(x,GU,d...), idx, domain_match) |>
        x -> GamsStructure.collect(Iterators.product(x...)) |>
        x -> GamsStructure.dropdims(x,dims=tuple(findall(size(x).==1)...)) |>
        x -> flatten.(x)


    #return idx
    data_dict = GamsStructure.data(P)
    length(idx) == 1 ? _setindexvalue!(P,value,idx[1]) :  _setindexvalue!.(Ref(P), value, idx)

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
            push!(code.args,:($add_parameter($GU,$parm_name, Parameter($GU,$sets,description = $desc))))
        end
    end
    return code
end
