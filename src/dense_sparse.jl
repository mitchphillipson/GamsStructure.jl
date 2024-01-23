
dimension(P::DenseSparseArray{T,N}) where {T,N} = N

function Base.size(P::DenseSparseArray)
    U = universe(P)
    return Tuple(length(U[i]) for i∈domain(P))
end


####################
### To Overwrite ###
####################

universe(P::DenseSparseArray) = nothing#GamsUniverse()
domain(P::DenseSparseArray{T,N}) where {T,N} = []
data(P::DenseSparseArray{T,N}) where {T,N} = Dict{NTuple{N,Any},T}()
description(P::DenseSparseArray) = ""

################
### getindex ###
################



@inline _convert_idx(x::Symbol,GU::GamsUniverse,d::Symbol) = (x==d || x∈GU[d].aliases || x∈GU[d]) ? (x == d || x∈GU[d].aliases ? [i for i∈GU[d]] : [x]) : throw(DomainError(x, "Symbol $x is neither a set nor an element of the set $d."))


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


function Base.getindex(P::DenseSparseArray{T,N},idx::CartesianIndex{N}) where {T,N}
    GU = universe(P)
    I = map((x,d) ->  GU[d][x].name ,Tuple(idx),domain(P))
    return P[I...]
end


"""

if v = [:a,:b,:c,:d,:e] and p = (2,2,1)

we expect output of 

[[:a,:b],[:c,:d],[:e]]
"""
function partition(v,p)
    ind = ((sum(p[i] for i∈1:n;init=1),sum(p[i] for i∈1:(n+1);init=1)-1) for n∈0:(length(p)-1))
    return [[v[i] for i∈a:b] for (a,b)∈ind]
end

function dimension(x)
    return 1
end

#Assume input has no masks
function Base.getindex(P::DenseSparseArray{T,N},idx::Vararg{Any,N}) where {T,N}
    
    GU = universe(P)
    d = domain(P)
    idx = map((x,d) -> _convert_idx(x,GU,d), idx, d)

    idx = collect(Iterators.product(idx...))
    idx = dropdims(idx,dims=tuple(findall(size(idx).==1)...))

    data_dict = data(P)
    length(idx) == 1 ? get(data_dict,idx[1],zero(T)) : get.(Ref(data_dict),idx,zero(T))
end


################
### setindex ###
################


function Base.setindex!(P::DenseSparseArray{T,N}, value, idx::Vararg{Any,N}) where {T,N}
    #domain_match = partition(domain(P),dimension.(idx))
    #@assert sum(length.(domain_match)) == dimension(P) "Not enough inputs, or something. Get a better error message"
    
    GU = universe(P)
    d = domain(P)
    idx = map((x,d) -> _convert_idx(x,GU,d), idx, d)
    
    idx = collect(Iterators.product(idx...))

    if length(idx) == 1
        _setindex!(P,value,idx[1])
    else
        _setindex!.(Ref(P), value, idx)
    end

end

function _setindex!(P::DenseSparseArray{T,N}, value, idx) where {T,N}
    d = data(P)

    if value == zero(T)
        delete!(d, idx)
    else
        d[idx] = value
    end

end



############
### Show ###
############


function Base.summary(io::IO,P::DenseSparseArray)
    d = domain(P)
    print(io,"Description: $(description(P))\nDomain: $(d)\n\n")
    return 
end


function Base.show(io::IO, ::MIME"text/plain", P::DenseSparseArray)
    summary(io,P)
    #println(io,":")
    if length(data(P)) > 0
        print(io,data(P))
    end
    return 
end

Base.show(io::IO, x::DenseSparseArray) = show(convert(IOContext, io), x)

function Base.show(io::IOContext, x::DenseSparseArray)
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
        (i, (key, value)) in enumerate(data(x)) if
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