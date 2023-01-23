function load_universe(path::String;to_load = [],nGU::GamsUniverse = GamsUniverse())

    #nGU = GamsUniverse()

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
            sets,desc,cols = parm
            cols = [e for e in cols]
            sets = Tuple([Symbol(e) for e in sets])
            add_parameter(nGU,key,GamsParameter(path,key,sets,nGU,cols,description = desc))
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


function load_universe!(GU::GamsUniverse,path::String;to_load = [])
    load_universe(path,to_load = to_load,nGU = GU)
end