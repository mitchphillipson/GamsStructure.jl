
function add_set(GU::GamsUniverse,set_name::Symbol,set::GamsSet)
    GU.sets[set_name] = set
end

function add_parameter(GU::GamsUniverse,parm_name::Symbol,parameter::Parameter)
    GU.parameters[parm_name] = parameter
end


function alias(GU::GamsUniverse,base_set::Symbol,alias::Symbol)
    #for alias in aliases
    new_set = deepcopy(GU[base_set])
    push!(new_set.aliases,base_set)
    for al in new_set.aliases
        push!(GU[al].aliases,alias)
    end
    add_set(GU,alias,new_set)
    return new_set

end

function sets(GU::GamsUniverse)
    return GU.sets
end

function parameters(GU::GamsUniverse)
    return GU.parameters
end

function Base.getindex(X::GamsUniverse,i)
    if i in keys(X.sets)
        return X.sets[i]
    elseif i in keys(X.parameters)
        return X.parameters[i]
    #else
    #    return X.scalars[i]
    end
    error("Key $i not found in universe")
end

function Base.show(io::IO, GU::GamsUniverse)
    out = "Sets\n\n"

    for (key,set) in GU.sets
        out *= "$key => $(set.description)"
        if length(set.aliases)>0
            out *=" => Aliases: $(set.aliases)"
        end
        out*="\n"
    end
    out *= "\nParameters\n\n"
    for (key,parm) in GU.parameters
        out *= "$key => $(parm.domain) => $(parm.description)\n"
    end

    return print(io,out)

    #return out

end

function Base.setindex!(GU::GamsUniverse,parm::Parameter,key::Symbol)
    GU.parameters[key] = deepcopy(parm)
end