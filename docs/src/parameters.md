# Parameters

```@docs
GamsParameter
GamsParameter(base_path::String,parm_name::Symbol,sets::Tuple{Vararg{Symbol}},GU::GamsUniverse;description = "")
GamsParameter(base_path::String,parm_name::Symbol,sets::Tuple{Vararg{Symbol}},GU::GamsUniverse,columns::Vector{Int};description = "")
@GamsParameters(GU,block)
@GamsParameters(GU,base_path,block)
domain(P::GamsParameter)
```