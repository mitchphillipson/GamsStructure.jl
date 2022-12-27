using GamsStructure
using JuMP
using Complementarity
using GLPK

sets = Dict()
@GamsSets(sets,"Examples/ex01_data",begin
:i, "Canning plants", false
:j, "Markets"
end)


parms = Dict()
@GamsParameters(parms,sets,"Examples/ex01_data",begin
:a, (:i,), "Capacity of platn i in cases"
:b, (:j,), "Demand at market j in cases"
:d, (:i,:j), "distance in thousands of miles"
end)

@GamsParameters(parms,sets,begin
:c, (:i,:j), "transport cost in thousands of dollars per case"
end)


f = 90 #freight in dollars per case per thousand miles"

begin
    local i = sets[:i]
    local j = sets[:j]
    parms[:c][i,j] = f*parms[:d][i,j]/1000
end

function transport_model(sets,parms)
    i = sets[:i]
    j = sets[:j]
    c = parms[:c]
    a = parms[:a]
    b = parms[:b]

    m = Model(GLPK.Optimizer)

    @variable(m,x[i,j]>=0)

    @objective(m, Min, sum(c[I,J]*x[I,J] for I∈i,J∈j))

    @constraint(m, supply[I=i], sum(x[I,J] for J∈j) <= a[I])
    @constraint(m, demand[J=j], sum(x[I,J] for I∈i) >= b[J])

    return m
end


function transport_model_mcp(sets,parms)
    i = sets[:i]
    j = sets[:j]
    c = parms[:c]
    a = parms[:a]
    b = parms[:b]

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


m = transport_model(sets,parms)
optimize!(m)
value.(m[:x])

model = transport_model_mcp(sets,parms)
solveMCP(model)


result_value.(model[:x])




