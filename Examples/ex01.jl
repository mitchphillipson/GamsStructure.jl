using GamsStructure
using JuMP
using Complementarity
using GLPK


GU = GamsUniverse()


@GamsSets(GU,"Examples/ex01_data",begin
:i, "Canning plants", false
:j, "Markets"
end)


@GamsParameters(GU,"Examples/ex01_data",begin
:a, (:i,), "Capacity of plant i in cases"
:b, (:j,), "Demand at market j in cases"
:d, (:i,:j), "distance in thousands of miles"
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
begin
    local i = GU[:i]
    local j = GU[:j]

    local f = scalar(GU[:f])

    GU[:c][i,j] = f*GU[:d][i,j]/1000
end

function transport_model(GU)
    i = GU[:i]
    j = GU[:j]
    
    c = GU[:c]
    a = GU[:a]
    b = GU[:b]

    m = Model(GLPK.Optimizer)

    @variable(m,x[i,j]>=0)

    @objective(m, Min, sum(c[I,J]*x[I,J] for I∈i,J∈j))

    @constraint(m, supply[I=i], sum(x[I,J] for J∈j) <= a[I])
    @constraint(m, demand[J=j], sum(x[I,J] for I∈i) >= b[J])

    return m
end


function transport_model_mcp(GU)
    i = GU[:i]
    j = GU[:j]

    c = GU[:c]
    a = GU[:a]
    b = GU[:b]

    m = MCPModel()

    @variable(m, w[i]>=0)
    @variable(m, p[j]>=0)
    @variable(m,x[i,j]>=0)


    @mapping(m,profit[I = i,J=j], w[I]+c[I,J]-p[J])
    @mapping(m,supply[I = i], a[I] - sum(x[I,J] for J∈j))
    @mapping(m,demand[J=j], sum(x[I,J] for I∈i) - b[J])

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




