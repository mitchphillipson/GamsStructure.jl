@testset "Loading and unloading a model" begin
    GU = GamsUniverse()

    @set(GU, I,"Test Set",begin
        a,"elm"
        b,"elm2"
    end)
    
    @alias(GU, I, J)
    
    @parameters(GU,begin
        p, (:I,:J), (description = "test parm",)
    end)
    

    cnt = 1
    for i∈I,j∈J
        p[i,j] = cnt
        cnt+=1
    end
    
    unload(GU,"test_data")

    nGU = load_universe("test_data")


    @test all(GU[:p] .≈ nGU[:p])
  
end