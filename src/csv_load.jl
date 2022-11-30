
"""
    GamsSet(base_path::String,set_name::Symbol;description = "",csv_description = true))

Load a GamsSet from a CSV file at location base_path/set_name.csv. 
"""
function GamsSet(base_path::String,set_name::Symbol;description = "",csv_description = true)
    F = CSV.File("$base_path/$set_name.csv",stringtype=String,silencewarnings=true)
	
    if csv_description
        cols = propertynames(F)[1:end-1]
    else
        cols = propertynames(F)
    end
    out = []
    for row in F
        if length(cols) ∈ [0,1]
            element = row[1]
        else
            element = Tuple([row[c] for c in cols])
        end
        desc = ""
        if csv_description && length(cols)!=0
            desc = row[end]
        end
        push!(out,GamsElement(element,desc))
    end

    return GamsSet(out,description)    
end

"""
    GamsSet(base_path::String,set_info::Tuple;description = "")

Load data from a single column of a CSV into a GamsSet.

The variable set_info is a tuple of the form (Symbol,Int) where the Int
is the column to load.

#Should be modified to be separate inputs.
"""
function GamsSet(base_path::String,set_info::Tuple;description = "")
    F = CSV.File("$base_path/$(set_info[1]).csv",stringtype=String,silencewarnings=true)
    
    elements = unique([row[set_info[2]] for row in F])
    out = [GamsElement(e) for e in elements]
    return GamsSet(out,description)
end


function GamsSet(base_path::String,set_info::Vector)
    if length(set_info) == 1
        return GamsSet(base_path,set_info[1])
    elseif length(set_info) == 2
        return GamsSet(base_path,set_info[1],description = set_info[2])
    elseif length(set_info) == 3
        return GamsSet(base_path,set_info[1],description = set_info[2],csv_description = set_info[3])
    end
    #return GamsSet(base_path,set_info...)
end

"""
    load_sets(set_names,base_path::String)

Load a potentially large number of sets and return a NamedTuple. 

At the moment the structure of set_names is a named tuple where the values have the 
following forms:

1. [set_name::Symbol, set_description::String = ""]
2. set_name::Symbol
"""
function load_sets(set_names,base_path::String)
    s = NamedTuple{keys(set_names)}(GamsSet(base_path,set) for set in set_names) 
    return s

end


"""
    load_sets!(sets,set_names,base_path)


"""
function load_sets!(sets,set_names,base_path)
    s = load_sets(set_names,base_path)
    return merge(sets,s)
end



function GamsParameter(base_path::String,parm_name::Symbol,columns::Vector,sets;description = "")

    return GamsParameter(base_path,parm_name,columns[1],sets,description = columns[2])

end

function GamsParameter(base_path::String,parm_name::Symbol,columns,sets;description = "")

    df = CSV.File("$base_path/$parm_name.csv",stringtype=String,silencewarnings=true)
    s = [sets[c] for c in columns]
    out = GamsParameter(s,description = description)
    #DenseAxisArray(zeros(length.(s)...),s...)

    for row in df
        out[Symbol.([row[c] for c in columns])...] = row[:value]
    end

    return out
end

function load_parameters(parameters_to_load,base_path,sets)
    np = Dict()
    for (parm,cols) in pairs(parameters_to_load)
        np[parm] =  GamsParameter(base_path,parm,cols,sets) 
    end
    return np
end

function load_parameters!(parameters, parameters_to_load,base_path,sets)
    p = load_parameters(parameters_to_load,base_path,sets)
    parms = merge(parameters,p)
    return parms
end


function GamsParameter(columns::Vector,sets;initial_value = zeros)
    sets = [sets[c] for c in columns[1]]
    return GamsParameter(sets,description = columns[2])
end

function GamsParameter(columns,sets; description = "",initial_value = zeros)
    sets = [sets[c] for c in columns]
    return GamsParameter(sets,description = description)
end

function empty_parameters(parameters_to_load,sets)
    np = Dict()
    for (parm,cols) in pairs(parameters_to_load)
        np[parm] = GamsParameter(cols,sets)
    end
    return np
end


function empty_parameters!(parameters,parameters_to_load,sets)
    np = empty_parameters(parameters_to_load,sets)
    p = merge(parameters,np)
    return p
end