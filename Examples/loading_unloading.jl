using GamsStructure

load_file = "Examples/loading_unloading"

"""
Step 1: Set up a small dataset. 
"""
GU = GamsUniverse()


@GamsSet(GU,:i,"This is only a test",begin
    a, "a"
    b, "b"
end)


@GamsParameters(GU,begin
    :x, (:i,:i), "First parameter. Notice repeated index."
    :y, (:i,), "Second parameter. This won't be unloaded."
end)



GU[:x][[:a],[:a]] = 5
GU[:x][[:a],[:b]] = -9
GU[:x][[:b],[:a]] = pi
GU[:x][[:b],[:b]] = 1


"""
Step 2: Unload the dataset. The directory will be created if it doesn't exist.
"""

unload(GU,load_file,to_unload = [:i,:x])

"""
Step 3: Load into a new variable and see they are the same, with the exception of :y
"""

nGU = load_universe(load_file)

println(nGU)
print(nGU[:x])


"""
Step 4: Selectively only load the set :i 

It is an error if you try to load a parameter before you've loaded the sets
"""

nnGU = load_universe(load_file,to_load = [:i])

println(nnGU)

load_universe!(nnGU,load_file,to_load = [:x])

print(nnGU)