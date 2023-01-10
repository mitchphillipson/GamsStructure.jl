using GamsStructure

"""
Step 1: Set up a small dataset. 
"""
GU = GamsUniverse()

add_set(GU,:i,GamsSet(
    (:a,"a"),
    (:b,"b"),
    description = "This is only a test"
))


@GamsParameters(GU,begin
    :x, (:i,:i), "First parameter. Notice repeated index."
    :y, (:i,), "Second parameter. This won't be unloaded."
end)

GU[:x][:a,:a] = 5
GU[:x][:a,:b] = -9
GU[:x][:b,:a] = pi
GU[:x][:b,:b] = 1


"""
Step 2: Unload the dataset. The directory will be created if it doesn't exist.
"""

unload(GU,"loading_unloading",to_unload = [:i,:x])

"""
Step 3: Load into a new variable and see they are the same, with the exception of :y
"""

nGU = load_universe("loading_unloading")

println(nGU)
print(nGU[:x])


"""
Step 4: Selectively only load the set :i 

It is an error if you try to load a parameter before you've loaded the sets
"""

nnGU = load_universe("loading_unloading",to_load = [:i])

println(nnGU)