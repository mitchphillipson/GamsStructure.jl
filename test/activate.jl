@testset "Loading and unloading a model" begin
    GU = GamsUniverse()

    @set(GU, i,"Test Set",begin
        a, "elm"
        b, "elm2"
    end)
    
    alias(GU,:i,:j)
    
    
    
    @parameters(GU,begin
        p, (:i,:j), (description = "test parm",)
    end)

    deactivate(GU,:i,:a)
    

    @parameters(GU,begin
        q, (:i,:j), (description = "test parm",)
    end)

    @test GU[:p][:i,:j] == [0 0]
    @test GU[:q][:i,:j] == [0 0]

    activate(GU,:i,:a)
    
    
    @test GU[:p][:i,:j] == [0 0; 0 0]
    @test GU[:q][:i,:j] == [0 0; 0 0]
    
end