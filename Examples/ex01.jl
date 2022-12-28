using GamsStructure
using JuMP
using Complementarity
using GLPK


GU = GamsUniverse()

#sets = Dict{Symbol,GamsSet}()
@GamsSets(GU,"Examples/ex01_data",begin
:i, "Canning plants", false
:j, "Markets"
end)



#parms = Dict{Symbol,GamsParameter}()
@GamsParameters(GU,"Examples/ex01_data",begin
:a, (:i,), "Capacity of plant i in cases"
:b, (:j,), "Demand at market j in cases"
:d, (:i,:j), "distance in thousands of miles"
end)

@GamsParameters(GU,begin
:c, (:i,:j), "transport cost in thousands of dollars per case"
end)


f = 90 #freight in dollars per case per thousand miles"

begin
    #sets = GU.sets
    local i = GU[:i]
    local j = GU[:j]
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




