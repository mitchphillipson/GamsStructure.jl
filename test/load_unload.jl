@testset "Loading and unloading a model" begin
    GU = GamsUniverse()

    add_set(GU,:i,GamsSet(
        (:a,"elm"),
        (:b,"elm2"),
        description = "Test set"
    ))

    alias(GU,:i,:j)

    add_parameter(GU,:p,GamsParameter((:i,:j),GU,description = "test parm"))

    cnt = 1
    for i∈GU[:i],j∈GU[:j]
        GU[:p][i,j] = cnt
        cnt+=1
    end

    unload(GU,"test/test_data")

    nGU = load_universe("test/test_data")


    @test all(GU[:p] .≈ nGU[:p])
  
end