struct GamsMask{N}
    universe::GamsUniverse
    domain::NTuple{N,Symbol}#Vector{Symbol}
    data::Dict{NTuple{N,Symbol},Bool}
    description::String
    GamsMask(GU,domain::Vararg{Symbol,N};description = "") where {N} = new{N}(GU,domain,Dict{NTuple{N,Symbol},Bool}(),description)
end

function domain(P::GamsMask)
    return P.domain
end

function dimension(M::GamsMask)
    return length(domain(M))
end

function Base.length(M::GamsMask)
    return prod(length(P.universe[i]) for i∈P.domain)
end

Base.iterate(sa::GamsMask, args...) = iterate(values(sa.data), args...)

function Base.size(P::GamsMask)
    return Tuple(length(P.universe[i]) for i∈P.domain)
end

function Base.axes(P::GamsMask)
    return Tuple([i for i∈P.universe[d]] for d∈domain(P))
end

function _convert_idx(x::Symbol,GU::GamsUniverse,d::Symbol)
    @assert (x==d || x∈GU[d]) "Symbol $x is neither a set nor an element of the set $d."
    if x == d
        return [i for i∈GU[d]]
    elseif x∈GU[d]
        return [x]
    end
end

function _convert_idx(x::Vector,GU::GamsUniverse,d::Symbol)
    @assert (all(i∈GU[d] for i∈x)) "At least one element of $x is not in set $d"
    return x
end

function _convert_idx(x::GamsSet,GU::GamsUniverse,d::Symbol)
    @assert x==GU[d] "The set\n\n$x\ndoes not match the domain set $d"
    return [i for i∈x]
end

function _convert_idx(x,GU::GamsUniverse,d::Symbol)
    @assert x∈ GU[d] "$x is out of bounds in set $d"
    return [x]
end


function Base.getindex(P::GamsMask{N},idx::CartesianIndex{N}) where {N}
    
    GU = P.universe
    I = map((x,d) ->  GU[d][x].name ,Tuple(idx),domain(P))
    return P[I...]
end

function Base.getindex(P::GamsMask{N},idx::Vararg{Any,N}) where {N}
    GU = P.universe
    idx = map((x,d)->_convert_idx(x,GU,d),idx,domain(P))
    X = collect(Iterators.product(idx...))

    if length(X) == 1
        return get(P.data,X[1],0)
    else
        return get.(Ref(P.data),X,0)
    end
end



Base.setindex!(P::GamsMask{N}, value, I::Vararg{Any,N}) where {N} = (P.data[I] = value)





function Base.summary(io::IO,P::GamsMask)
    d = domain(P)
    print(io,"Description: $(P.description)\nDomain: $(d)\n\n")
    return 
end


function Base.show(io::IO, ::MIME"text/plain", P::GamsMask)
    summary(io,P)
    #println(io,":")
    if length(P.data) > 0
        print(io,P.data)
    end
    return 
end

Base.show(io::IO, x::GamsMask) = show(convert(IOContext, io), x)

function Base.show(io::IOContext, x::GamsMask)
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