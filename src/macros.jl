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

macro parameter(GU, name, domain, kwargs...)

    #universe = esc(universe_sym)
    constr_call = :(Parameter($(esc(GU)),  $domain))
    _add_kw_args(constr_call, kwargs)

    return :($(esc(name)) = add_parameter($(esc(GU)), $(QuoteNode(name)), $constr_call))
end


macro parameters(model, block)
    return _plural_macro_code(model, block, Symbol("@parameter");entries_to_grab = 2)
end



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


macro extract_sets_as_vector(GU, sets...)
    code = quote end
    for s∈sets
        push!(code.args, :($(esc(s)) = [e for e∈$GU[$(QuoteNode(s))]]))
    end
    return code
end


macro extract(GU, vars...)
    code = quote end
    for s∈vars
        push!(code.args, :($(esc(s)) = $(esc(GU))[$(QuoteNode(s))]))
    end
    return code
end