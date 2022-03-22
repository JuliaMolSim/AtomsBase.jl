using AtomsBase
using Test

@testset "Chemical formula" begin
    @test chemical_formula([:H])                  == "H"
    @test chemical_formula([:H, :H])              == "H₂"
    @test chemical_formula([:H, :O, :H])          == "H₂O"
    @test chemical_formula([:O, :H, :O, :H])      == "H₂O₂"
    @test chemical_formula([:Ga, :N, :O, :H, :H]) == "GaH₂NO"
end

