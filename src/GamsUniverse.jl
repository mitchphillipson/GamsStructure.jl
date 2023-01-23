

function add_set(GU::GamsUniverse,set_name::Symbol,set::GamsSet)
    GU.sets[set_name] = set
end

function add_parameter(GU::GamsUniverse,parm_name::Symbol,parameter::GamsParameter)
    GU.parameters[parm_name] = parameter
end

function add_scalar(GU::GamsUniverse,scalar_name::Symbol,scalar)
    GU.scalars[scalar_name] = scalar
end


function alias(GU::GamsUniverse,base_set::Symbol,alias::Symbol)
    new_set = deepcopy(GU[base_set])
    add_set(GU,alias,new_set)
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
    else
        return X.scalars[i]
    end
end

function Base.setindex!(X::GamsUniverse,scalar::Number,scalar_name::Symbol)
    set_scalar!(X[scalar_name],scalar)
end


function Base.show(io::IO, GU::GamsUniverse)
    out = "Sets\n\n"

    for (key,set) in GU.sets
        out *= "$key => $(set.description)\n"
    end
    out *= "\nParameters\n\n"
    for (key,parm) in GU.parameters
        out *= "$key => $(parm.sets) => $(parm.description)\n"
    end
    out *= "\nScalars\n\n"
    for (key,s) in GU.scalars
        out *= "$key => $(s.scalar) => $(s.description)\n"
    end

    print(out)

    return out

end

function Base.setindex!(GU::GamsUniverse,parm::GamsParameter,key::Symbol)
    GU.parameters[key] = deepcopy(parm)
end