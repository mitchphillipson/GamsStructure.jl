function load_universe(path::String)

    nGU = GamsUniverse()

    #info = Dict()
     #do f
        #global info
    info=JSON.parse(open("$path/gams_info.json", "r"))  # parse and transform data
    #end


    for (key,desc) in info["set"]
        key = Symbol(key)
        add_set(nGU,key,GamsSet(path,key,description = desc))
    end


    for (key,parm) in info["parm"]
        key = Symbol(key)
        sets,desc = parm
        sets = Tuple([Symbol(e) for e in sets])
        add_parameter(nGU,key,GamsParameter(path,key,sets,nGU,description = desc))
    end

    for (key,scalar) in info["scalar"]
        key = Symbol(key)
        add_scalar(nGU,key,GamsScalar(scalar["scalar"],description = scalar["description"]))
    end

    return nGU

end