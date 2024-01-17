struct new_parameter{T<:Number,N} <: AbstractArray{T,N}
    universe::GamsUniverse
    domain::NTuple{N,Symbol}
    data::Dict{NTuple{N,Any},T}
    description::String
    new_parameter(universe::GamsUniverse,domain::Tuple{Vararg{Symbol}},description::String) = new{Float64,length(domain)}(GU,domain,Dict{Any,Float64}(),description)
end


function Base.length(P::new_parameter)
    return prod(length(P.universe[i]) for i∈P.domain)
end

Base.iterate(sa::new_parameter, args...) = iterate(values(sa.data), args...)

function domain(P::new_parameter)
    return P.domain
end

function dimension(M::new_parameter)
    return length(domain(M))
end

function Base.size(P::new_parameter)
    return Tuple(length(P.universe[i]) for i∈P.domain)
end

function Base.axes(P::new_parameter)
    return Tuple([i for i∈P.universe[d]] for d∈domain(P))
end

#Base.CartesianIndices(P::new_parameter) = CartesianIndices(size(P))
Base.eachindex(P::new_parameter) = CartesianIndices(size(P))

#function Base.getindex(P::new_parameter{T,N},I::Vararg{Any,N}) where {T,N} 
    
#    get(P.data,I,zero(T))

#end


Base.setindex!(P::new_parameter{T,N}, value, I::Vararg{Any,N}) where {T,N} = (P.data[I] = value)




function Base.summary(io::IO,P::new_parameter)
    d = domain(P)
    print(io,"Description: $(P.description)\nDomain: $(d)\n\n")
    return 
end


function Base.show(io::IO, ::MIME"text/plain", P::new_parameter)
    summary(io,P)
    #println(io,":")
    if length(P.data) > 0
        print(io,P.data)
    end
    return 
end

Base.show(io::IO, x::new_parameter) = show(convert(IOContext, io), x)

function Base.show(io::IOContext, x::new_parameter)
    summary(io,x)
    if isempty(x)
        return show(io, MIME("text/plain"), x)
    end
    limit = get(io, :limit, false)::Bool
    half_screen_rows = limit ? div(displaysize(io)[1] - 8, 2) : typemax(Int)
    if !haskey(io, :compact)
        io = IOContext(io, :compact => true)
    end
    
    key_strings = [
        (join(key, ", "), value) for
        (i, (key, value)) in enumerate(x.data) if
        i < half_screen_rows || i > length(x) - half_screen_rows
    ]
    
    sort!(key_strings; by = x -> x[1])
    pad = maximum(length(x[1]) for x in key_strings)
    
    for (i, (key, value)) in enumerate(key_strings)
        print(io, "  [", rpad(key, pad), "]  =  ", value)
        if i != length(key_strings)
            println(io)
            if i == half_screen_rows
                println(io, "   ", " "^pad, "   \u22ee")
            end
        end
    end
    
    return
end