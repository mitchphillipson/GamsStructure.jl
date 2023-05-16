
"""
    load_universe(path::String;
                  to_load = [],
                  nGU::GamsUniverse = GamsUniverse(),
                  raw_text=true)

Load a universe from the path.

`path` - Universe location

`to_load` - Load specific sets and parameters

`nGU` - Add sets and parameters to an existing universe

`raw_text` - Denote if a universe is saved as raw_text or in a binary format.
"""
function load_universe(path::String;to_load = [],nGU::GamsUniverse = GamsUniverse(),raw_text=true)

    info=JSON.parse(open("$path/gams_info.json", "r"))  # parse and transform data

    for (key,(desc,aliases)) in info["set"]
        key = Symbol(key)
        aliases = [Symbol(s) for s∈aliases if s∈keys(info["set"]) && (to_load == [] || Symbol(s)∈to_load)]
        if to_load == [] || key ∈ to_load
            add_set(nGU,key,GamsSet(path, key, description = desc, aliases=aliases))
        end
    end

    if raw_text
        for (key,parm) in info["parm"]
            name = Symbol(key)
            if to_load == [] || key ∈ to_load
                sets,desc,cols = parm
                cols = [e for e in cols]
                domain = Tuple([Symbol(e) for e in sets])
                parm_path = joinpath(path,"$name.csv")
                load_parameter!(nGU,parm_path,name,domain;description = desc,columns=cols)
                #add_parameter(nGU,key,GamsParameter(path,key,sets,nGU,cols,description = desc))
            end
        end
    else
        parameters = h5open("$path/parameters.h5","r")
        for (key,parm) in info["parm"]
            name = Symbol(key)
            if to_load == [] || name ∈ to_load
                sets,desc,cols = parm
                sets = Tuple([Symbol(e) for e in sets])
                add_parameter(nGU,name,GamsParameter(nGU,sets,desc))
                nGU[name][sets...] = read(parameters[key])
            end
        end
    end

    #for (key,scalar) in info["scalar"]
    #    key = Symbol(key)
    #    if to_load == [] || key ∈ to_load
    #        add_scalar(nGU,key,GamsScalar(scalar["scalar"],description = scalar["description"]))
    #    end
    #end


    #How should aliases be handled?
    for (set_name,set) in nGU.sets
        #for a∈set.aliases
        #    if 
        #set.aliases = [a for a∈set.aliases if a∈keys(nGU.sets)] #only keep the aliases for exsting sets
        for a∈set.aliases #Make sure aliases are reflexive.
            a_set = nGU[a]
            if set_name∉a_set.aliases
                push!(a_set.aliases,set_name)
            end
        end
    end

    return nGU

end


function load_universe!(GU::GamsUniverse,path::String;to_load = [])
    load_universe(path,to_load = to_load,nGU = GU)
end




"""
    load_parameter(GU::GamsUniverse,
                   path_to_parameter::String,
                   domain::Tuple{Vararg{Symbol}};
                   description::String = "",
                   columns::Union{Vector{Int},Missing} = missing,
                   value_name = :value
                   )

Load and return a parameter from a CSV file.

`GU` - Parent universe. The parameter will not be added to the universe

`path_to_parameter` - Where the parameter lives

`domain` - A tuple of the names of the domain sets

`description` - A description of the parameter. Defaults to empty string

`columns` - If the names in the CSV don't match the set names, use this to specify which 
columns correspond to the sets.

`value_name` - The name of the column where the values live. Can also be an integer.

This function requires a specific format of CSV file:

|set_1|set_2|value|
|---|---|---|
|...|...|...|

By default, the function expects the columns names in the CSV to match the set names,
however, this can be modified using the columns parameter. 

"""
function load_parameter(GU::GamsUniverse,
                        path_to_parameter::String,
                        domain::Tuple{Vararg{Symbol}};
                        description::String = "",
                        columns::Union{Vector{Int},Missing} = missing,
                        value_name = :value
                        )

    df = CSV.File("$path_to_parameter",stringtype=String,silencewarnings=true)
    out = GamsParameter(GU,domain,description = description)

    #If columns is set, load the data directly from the columns
    if !ismissing(columns)
        domain = columns
    end

    for row in df
        elm = [[Symbol(row[c])] for c in domain]
        out[elm...] = row[value_name]
    end

    return out
end
    
"""
    load_parameter!(GU::GamsUniverse,
                    path_to_parameter::String,
                    name::Symbol,
                    domain::Tuple{Vararg{Symbol}};
                    description::String = "",
                    columns::Union{Vector{Int},Missing} = missing,
                    value_name = :value
                    )

Identical to `load_parameter` except it includes the parameter in GU.
"""
function load_parameter!(GU::GamsUniverse,
                        path_to_parameter::String,
                        name::Symbol,
                        domain::Tuple{Vararg{Symbol}};
                        description::String = "",
                        columns::Union{Vector{Int},Missing} = missing,
                        value_name = :value
                        )

    P = load_parameter(GU,path_to_parameter,domain; description = description,columns=columns,value_name=value_name)

    add_parameter(GU,name,P)

end

"""
    load_set(path::String;description = "")

Load a GamsSet from a CSV file at the given location. 

Sets must be one dimensional (at least for now) and it's assumed the first column are the elements
and the second column is the description. If the second column is missing, the description is ""
"""
function load_set(path::String;description = "")
    F = CSV.File(path,stringtype=String,silencewarnings=true)
	
    out = []
    cols = propertynames(F)
    for row in F
        element = row[1]
        desc = ""
        if length(cols)==2 && !(ismissing(row[2]))
            desc = row[2]
        end
        push!(out,GamsElement(element,desc))
    end

    return GamsSet(out,description) 
end

"""
    load_set!(GU::GamsUniverse,set_name::Symbol,path::String;description="")

Same as load_set, except the set gets added to the universe.
"""
function load_set!(GU::GamsUniverse,set_name::Symbol,path::String;description="")
    S = load_set(path;description=description)
    add_set(GU,set_name,S)
end