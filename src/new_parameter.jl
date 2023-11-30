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