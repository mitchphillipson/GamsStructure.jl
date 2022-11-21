using GamsStructure
using JuMP


S = GamsSet(
    (("a",:c),"h"),
    (:b,"c"),
    (:badf,"LDKJF"),
    description = "This is a test set"
);  

m = Model()

@variable(m,X[S])

P = GamsParameter(S)

P.value
