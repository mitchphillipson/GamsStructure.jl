function unload(S::GamsSet,path,set_name)
    out = [[set_name,"description"]]
    tmp = [[elm.name,elm.description] for elm in S.elements]
    append!(out,tmp)
    writedlm("$path/$set_name.csv",out,",")
end

function unload(GU::GamsUniverse,P::Parameter,path,parm_name;raw_text=true)

    if raw_text
        out = Vector{Vector{Any}}()

        tmp = [string(s) for s in P.domain]
        push!(tmp,"value")
        push!(out,tmp)

        axes = [[e for e∈GU[s]] for s∈P.domain]
        for idx ∈ Iterators.product(axes...)
            tmp = Vector{Any}()
            append!(tmp,[idx...])
            ind = [[i] for i∈idx]
            push!(tmp,P[ind...])
            push!(out,tmp)
        end

        writedlm("$path/$parm_name.csv",out,",")

    else
        h5write("$path/parameters.h5",String(parm_name),P.value)
    end
end


"""
    unload(GU::GamsUniverse,
           path;
           to_unload = [],
           raw_text = true)

Save a universe from the path.

`GU` - The universe to save

`path` - Universe location

`to_unload` - Unload specific sets and parameters

`raw_text` - Denote if a universe is saved as raw_text or in a binary format.
"""
function unload(GU::GamsUniverse,path;to_unload = [],raw_text = true)
    info = Dict()
    info[:set] = Dict()
    info[:parm] = Dict()
    info[:scalar] = Dict()

    if !(isdir(path))
        mkdir(path)
    end

    for (key,set) in GU.sets
        if to_unload == [] || key∈to_unload
            unload(set,path,key)
            info[:set][key] = [set.description,set.aliases]
        end
    end

    for (key,parm) in GU.parameters
        if to_unload == [] || key∈to_unload
            unload(GU,parm,path,key;raw_text=raw_text)
            cols = collect(1:length(parm.domain))
            info[:parm][key] = [parm.domain,parm.description,cols]
        end

    end

    #for (key,scalar) in GU.scalars
    #    if to_unload == [] || key∈to_unload
    #        info[:scalar][key] = Dict("scalar" => scalar.scalar, "description" => scalar.description)
    #    end
    #end

    open("$path/gams_info.json","w") do f
        write(f,json(info))
    end
end