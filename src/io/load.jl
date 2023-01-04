function load_universe(path::String;to_load = [])

    nGU = GamsUniverse()

    #info = Dict()
     #do f
        #global info
    info=JSON.parse(open("$path/gams_info.json", "r"))  # parse and transform data
    #end


    for (key,desc) in info["set"]
        key = Symbol(key)
        if to_load == [] || key ∈ to_load
            add_set(nGU,key,GamsSet(path,key,description = desc))
        end
    end


    for (key,parm) in info["parm"]
        key = Symbol(key)
        if to_load == [] || key ∈ to_load
            sets,desc = parm
            sets = Tuple([Symbol(e) for e in sets])
            add_parameter(nGU,key,GamsParameter(path,key,sets,nGU,description = desc))
        end
    end

    for (key,scalar) in info["scalar"]
        key = Symbol(key)
        if to_load == [] || key ∈ to_load
            add_scalar(nGU,key,GamsScalar(scalar["scalar"],description = scalar["description"]))
        end
    end

    return nGU

end