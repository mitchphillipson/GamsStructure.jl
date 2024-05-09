# This function is copied from JuMP
function _add_kw_args(call, kw_args)
    for kw in kw_args
        @assert Meta.isexpr(kw, :(=))
        push!(call.args, esc(Expr(:kw, kw.args...)))
    end
end

#Stolen from JuMP
function _plural_macro_code(model, block, macro_sym;entries_to_grab = 1)
    if !Meta.isexpr(block, :block)
        error(
            "Invalid syntax for $(macro_sym)s. The second argument must be a " *
            "`begin end` block. For example:\n" *
            "```julia\n$(macro_sym)s(model, begin\n    # ... lines here ...\nend)\n```.",
        )
    end
    @assert block.args[1] isa LineNumberNode
    last_line = block.args[1]
    code = quote end #Expr(:tuple) #I don't know why this works in JuMP, but not for me. Perhaps a Julia 1.10 thing
    jump_macro = Expr(:., GamsStructure, QuoteNode(macro_sym)) #Change Main to module name here
    for arg in block.args
        if arg isa LineNumberNode
            last_line = arg
        elseif Meta.isexpr(arg, :tuple)  # Line with commas.
            macro_call = Expr(:macrocall, jump_macro, last_line, model)
            # Because of the precedence of "=", Keyword arguments have to appear
            # like: `x, (start = 10, lower_bound = 5)`
            for i∈1:entries_to_grab
                ex = popfirst!(arg.args)
                push!(macro_call.args,ex)
            end
            for ex in arg.args
                if Meta.isexpr(ex, :tuple) # embedded tuple
                    append!(macro_call.args, ex.args)
                else
                    push!(macro_call.args, ex)
                end
            end
            push!(code.args, esc(macro_call))
        else  # Stand-alone symbol or expression.
            macro_call = Expr(:macrocall, jump_macro, last_line, model, arg)
            push!(code.args, esc(macro_call))
        end
    end
    return code
end

"""
    @parameter(GU, name, domain, kwargs...)

Create a parameter in the universe. Also puts the name in the local
namespace.

```
@parameter(GU, p, (:I,:J), description = "this is p")
```
This assumes both I and J are sets already in GU. The description
is an optional (but recommended) argument. 

"""
macro parameter(GU, name, domain, kwargs...)

    #universe = esc(universe_sym)
    constr_call = :(Parameter($(esc(GU)),  $domain))
    _add_kw_args(constr_call, kwargs)

    return :($(esc(name)) = add_parameter($(esc(GU)), $(QuoteNode(name)), $constr_call))
end

"""
    @parameters(model, block)

Plural version of `@parameter`. 

```
@parameters(GU, begin
    p, (:i,:j), (description = "This is p",)
    t, :i
```
This create two parameters, p and t. p will have a description.
"""
macro parameters(model, block)
    return _plural_macro_code(model, block, Symbol("@parameter");entries_to_grab = 2)
end

"""
    @set(GU, set_name, description, block)

Macro to create a GamsSet. 

```
@set(GU,I,"example set",begin
    element_1, "Description 1"
    element_2, "Description 2"
    element_3, "Description 3"
end)
```

This will put the set I in the local name space as well.

"""
macro set(GU, set_name, description, block)
    universe = esc(GU)
    if !(isa(block,Expr) && block.head == :block)
        error("Problem")
    end
    elements = []
    for it in block.args
        if isexpr(it,:tuple)
            elm = it.args[1]
            desc = ""
            if length(it.args)>=2
                desc = it.args[2]
            end
            push!(elements,GamsElement(elm,desc))
        end
    end  

    constr_call = :(GamsSet($elements,$(esc(description))))

    return :($(esc(set_name)) = add_set($(esc(GU)), $(QuoteNode(set_name)), $constr_call))
end

"""
    @extract_sets_as_vector(GU, sets...)

Load the sets in the local namespace as vectors.

For example, if I and j are sets in GU, then
```
@extract_sets_as_vector(GU, I, J)
```
will make both I and J be vectors in the local namespace.
"""
macro extract_sets_as_vector(GU, sets...)
    code = quote end
    for s∈sets
        if s isa Expr
            tmp = s.args
            push!(code.args, :($(esc(tmp[3])) = [e for e∈$(esc(GU))[$(QuoteNode(tmp[2]))]]))
        else
            push!(code.args, :($(esc(s)) = [e for e∈$(esc(GU))[$(QuoteNode(s))]]))
        end
    end
    return code
end


"""
    @extract(GU, vars...)

Load the vars in the local namespace. This will preserve their type.

You can load either sets or parameters by name. If I and j are sets
and p is a parameter in GU then
```
@extract(GU, I, j=>J, p)
```
will put each in the local namespace and J = GU[:j]
"""
macro extract(GU, vars...)
    code = quote end
    for s∈vars
        if s isa Expr
            tmp = s.args
            push!(code.args, :($(esc(tmp[3])) = $(esc(GU))[$(QuoteNode(tmp[2]))]))
        else
            push!(code.args, :($(esc(s)) = $(esc(GU))[$(QuoteNode(s))]))
        end
    end
    return code
end

"""
   @alias(GU, base_set, new_sets...)

Add aliases of the base set with names given by new_sets.

```
@alias(GU, I, J, K)
```
Then J and K will be deep copies of I in the local namespace and
added to GU as sets.
"""
macro alias(GU, base_set, new_sets...)
    code = quote end
    GU = esc(GU)
    for s∈new_sets
        push!(code.args, :($(esc(s)) = alias($GU, $(QuoteNode(base_set)), $(QuoteNode(s)))))
    end
    return code
end