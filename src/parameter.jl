

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
