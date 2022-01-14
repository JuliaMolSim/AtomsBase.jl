using Test

@testset "AtomsBase.jl" begin
    include("interface.jl")
    include("fast_system.jl")
    include("atom.jl")
end
