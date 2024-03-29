
function Base.:+(X::GamsScalar,y::Number)
    return X.scalar+y
end

function Base.:+(y::Number,X::GamsScalar)
    return y+X.scalar
end

function Base.:+(X::GamsScalar,Y::GamsScalar)
    return X.scalar+Y.scalar
end

function Base.:*(X::GamsScalar,y::Number)
    return X.scalar*y
end

function Base.:*(y::Number,X::GamsScalar)
    return y*X.scalar
end

function Base.:*(X::GamsScalar,Y::GamsScalar)
    return X.scalar*Y.scalar
end


function Base.:-(X::GamsScalar,y::Number)
    return X.scalar-y
end

function Base.:-(y::Number,X::GamsScalar)
    return y-X.scalar
end

function Base.:-(X::GamsScalar,Y::GamsScalar)
    return X.scalar-Y.scalar
end

function Base.:/(X::GamsScalar,y::Number)
    return X.scalar/y
end

function Base.:/(y::Number,X::GamsScalar)
    return y/X.scalar
end

function Base.:/(X::GamsScalar,Y::GamsScalar)
    return X.scalar/Y.scalar
end

function Base.:^(X::GamsScalar,y::Number)
    return X.scalar^y
end

function Base.:^(y::Number,X::GamsScalar)
    return y^X.scalar
end

function Base.:^(X::GamsScalar,Y::GamsScalar)
    return X.scalar^Y.scalar
end

macro GamsScalars(GU,block)
    GU = esc(GU)
    if !(isa(block,Expr) && block.head == :block)
        error()
    end

    code = quote end
    for it in block.args
        if isexpr(it,:tuple)
            scalar_name = it.args[1]
            scalar = it.args[2]
            desc = ""
            if length(it.args) >= 3
                desc = it.args[3]
            end
            push!(code.args,:($add_scalar($GU,$scalar_name, GamsScalar($scalar,description = $desc))))
        end
    end
    return code
end