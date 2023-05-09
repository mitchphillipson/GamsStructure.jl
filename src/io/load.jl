
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

    #nGU = GamsUniverse()

    #info = Dict()
     #do f
        #global info
    info=JSON.parse(open("$path/gams_info.json", "r"))  # parse and transform data
    #end


    for (key,(desc,aliases)) in info["set"]
        key = Symbol(key)
        aliases = [Symbol(s) for s∈aliases if s∈keys(info["set"]) && (to_load == [] || Symbol(s)∈to_load)]
        
        if to_load == [] || key ∈ to_load
            add_set(nGU,key,GamsSet(path, key, description = desc, aliases=aliases))
        end
    end

    if raw_text
        for (key,parm) in info["parm"]
            key = Symbol(key)
            if to_load == [] || key ∈ to_load
                sets,desc,cols = parm
                cols = [e for e in cols]
                sets = Tuple([Symbol(e) for e in sets])
                add_parameter(nGU,key,GamsParameter(path,key,sets,nGU,cols,description = desc))
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

    for (key,scalar) in info["scalar"]
        key = Symbol(key)
        if to_load == [] || key ∈ to_load
            add_scalar(nGU,key,GamsScalar(scalar["scalar"],description = scalar["description"]))
        end
    end


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