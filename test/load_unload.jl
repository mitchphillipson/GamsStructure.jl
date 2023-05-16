@testset "Loading and unloading a model" begin
    GU = GamsUniverse()

    @create_set!(GU,:i,"Test Set",begin
        a,"elm"
        b,"elm2"
    end)
    
    alias(GU,:i,:j)
    
    @create_parameters(GU,begin
        :p, (:i,:j), "test parm"
    end)
    

    cnt = 1
    for i∈GU[:i],j∈GU[:j]
        GU[:p][[i],[j]] = cnt
        cnt+=1
    end
    
    unload(GU,"test_data")

    nGU = load_universe("test_data")


    @test all(GU[:p] .≈ nGU[:p])
  
end