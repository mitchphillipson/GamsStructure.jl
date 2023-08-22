# Parameters

```@docs
GamsParameter
load_parameter(GU::GamsUniverse,
                        path_to_parameter::String,
                        domain::Tuple{Vararg{Symbol}};
                        description::String = "",
                        columns::Union{Vector{Int},Missing} = missing,
                        value_name = :value
                        )
load_parameter!(GU::GamsUniverse,
                path_to_parameter::String,
                name::Symbol,
                domain::Tuple{Vararg{Symbol}};
                description::String = "",
                columns::Union{Vector{Int},Missing} = missing,
                value_name = :value
                )
@load_parameters!(GU,base_path,block)
@create_parameters(GU,block)
domain(P::GamsParameter)
```