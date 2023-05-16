""" 
    @load_parameters!(GU,base_path,block)

Load parameters from a file. This will search `base_path\\name.csv`.

```
@load_parameters!(GU,begin
    :P, (:set_1,:set_2), description => "Description 1"
    :X, (:set_1,), kwpairs*
end)
```

kwpairs supported:

`description`

`columns`

`value_name`

`file_name` - Changes the path to base_path\\file_name

"""
macro load_parameters!(GU,base_path,block)
    GU = esc(GU)
    base_path = esc(base_path)
    if !(isa(block,Expr) && block.head == :block)
        error()
    end

    code = quote end
    for it in block.args
        if isexpr(it,:tuple)
            parm_name = it.args[1]
            domain = it.args[2]
            path = :("$($base_path)/$($parm_name).csv")
            desc = ""
            columns = missing
            value_name = QuoteNode(:value)
            for elm in it.args[3:end]
                if elm.args[1] != :(=>)
                    continue
                end
                if elm.args[2] == :description
                    desc = elm.args[3]
                elseif elm.args[2] == :columns
                    columns = elm.args[3]
                elseif elm.args[2] == :value_name
                    value_name = esc(elm.args[3])
                elseif elm.args[2] == :file_name
                    path = :("$($base_path)/$($(elm.args[3]))")
                end
            end
            push!(code.args, :($load_parameter!($GU,$path,$parm_name,$domain;
                                                description = $desc,
                                                columns = $columns,
                                                value_name = $value_name
                                                )))

        end
    end
    return code
end