using GamsStructure
using JuMP
using Complementarity
using GLPK


GU = GamsUniverse()


@GamsSets(GU,"Examples/ex01_data",begin
    :i, "Canning plants"
    :j, "Markets"
end)


@GamsParameters(GU,"Examples/ex01_data",begin
    :a, (:i,), "Capacity of plant i in cases"
    :b, (:j,), "Demand at market j in cases"
    :d, (:i,:j), "distance in thousands of miles", [1,2] #notice the file d.csv has the wrong columns
end)

@GamsParameters(GU,begin
    :c, (:i,:j), "transport cost in thousands of dollars per case"
end)

@GamsScalars(GU,begin
    :f, 90, "freight in dollars per case per thousand miles"
end)


"""
In this block, we use the code

f = scalar(GU[:f])

as an example of extracting a scalar value. This isn't necessary in 
this code, it works to use GU[:f] in place of f in the following line.

However, if used in a JuMP model, extracting this information is necessary
as JuMP doesn't recognize the datatype and will throw and error.
"""
GU[:c][:i,:j] = scalar(GU[:f])*GU[:d][:i,:j]/1000


function transport_model(GU)
    #Extract sets, only for convenience 
    I = GU[:i]
    J = GU[:j]
    
    #Same with parameters
    c = GU[:c]
    a = GU[:a]
    b = GU[:b]

    m = Model(GLPK.Optimizer)

    @variable(m,x[I,J]>=0)

    @objective(m, Min, sum(c[:i,:j].*x))
    #@objective(m,Min, sum(c[[i],[j]]*x[i,j] for i∈I,j∈J))

    @constraint(m, supply[i=I], sum(x[i,j] for j∈J) <= a[[i]])
    @constraint(m, demand[j=J], sum(x[i,j] for i∈I) >= b[[j]])

    return m
end


function transport_model_mcp(GU)
    I = GU[:i]
    J = GU[:j]

    c = GU[:c]
    a = GU[:a]
    b = GU[:b]

    m = MCPModel()

    @variable(m, w[I]>=0)
    @variable(m, p[J]>=0)
    @variable(m,x[I,J]>=0)


    @mapping(m,profit[i = I,j=J], w[i]+c[[i],[j]]-p[j])
    @mapping(m,supply[i = I], a[[i]] - sum(x[i,j] for j∈J))
    @mapping(m,demand[j=J], sum(x[i,j] for i∈I) - b[[j]])

    @complementarity(m,profit,x)
    @complementarity(m,supply,w)
    @complementarity(m,demand,p)


    return m

end


m = transport_model(GU)
optimize!(m)
value.(m[:x])

model = transport_model_mcp(GU)
solveMCP(model)


result_value.(model[:x])




