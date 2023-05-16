# Sets


```@docs
GamsSet
GamsSet(e::Tuple;description = "")   
GamsSet(x::Vector{Tuple{Symbol,String}};description = "")
GamsSet(e::Vector{Symbol};description = "")  
GamsDomainSet(base_path::String,parm_name::Symbol,column::Int;description = "")
@create_set!
load_set
load_set!
@load_sets!
```
