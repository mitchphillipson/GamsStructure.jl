using GamsStructure
using JuMP



@macroexpand(@GamsSet(begin
x, "test"
b, "dk"
end
))


@GamsSet begin
x, "t"
b, "c"
end

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




