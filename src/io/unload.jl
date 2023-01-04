function unload(S::GamsSet,path,set_name)
    out = [[set_name,"description"]]
    tmp = [[elm.name,elm.description] for elm in S.elements]
    append!(out,tmp)
    writedlm("$path/$set_name.csv",out,",")
end


function unload(P::GamsParameter,path,parm_name)

    out = Vector{Vector{Any}}()

    tmp = [string(s) for s in P.sets]
    push!(tmp,"value")
    push!(out,tmp)
    for idx ∈ Iterators.product(P.value.axes...)
        tmp = Vector{Any}()
        append!(tmp,[idx...])
        push!(tmp,P[idx...])
        push!(out,tmp)
    end

    writedlm("$path/$parm_name.csv",out,",")
end


function unload(GU::GamsUniverse,path;to_unload = [])
    info = Dict()
    info[:set] = Dict()
    info[:parm] = Dict()
    info[:scalar] = Dict()

    path = "data/"

    for (key,set) in GU.sets
        if to_unload == [] || key∈to_unload
            unload(set,path,key)
            info[:set][key] = set.description
        end
    end

    for (key,parm) in GU.parameters
        if to_unload == [] || key∈to_unload
            unload(parm,path,key)
            info[:parm][key] = [parm.sets,parm.description]
        end

    end

    for (key,scalar) in GU.scalars
        if to_unload == [] || key∈to_unload
            info[:scalar][key] = Dict("scalar" => scalar.scalar, "description" => scalar.description)
        end
    end

    open("$path/gams_info.json","w") do f
        write(f,json(info))
    end
end