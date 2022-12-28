

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
    add_set(GU,alias,GU[base_set])
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


