# Sets


```@docs
GamsSet
GamsSet(e::Tuple;description = "")   
GamsSet(x::Vector{Tuple{Symbol,String}};description = "")
GamsSet(e::Vector{Symbol};description = "")  
GamsSet(base_path::String,set_name::Symbol;description = "",csv_description = true,aliases = [])
GamsDomainSet(base_path::String,parm_name::Symbol,column::Int;description = "")
@GamsSet
@GamsSets
```
