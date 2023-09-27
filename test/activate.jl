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

    deactivate(GU,:i,:a)
    

    @create_parameters(GU,begin
        :q, (:i,:j), "test parm"
    end)

    @test GU[:p][:i,:j] == [0 0]
    @test GU[:q][:i,:j] == [0 0]

    activate(GU,:i,:a)
    
    
    @test GU[:p][:i,:j] == [0 0; 0 0]
    @test GU[:q][:i,:j] == [0 0; 0 0]
    
end