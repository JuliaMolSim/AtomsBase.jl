
using AtomsBase
using Unitful
using UnitfulAtomic
using Test

##

@testset "ChemicalSpecies" begin 

symbols = [:H, :He, :Li, :Be, :B, :C, :N, :O, :F, :Ne]
nneut = collect(1:10); nneut[1] = 0; nneut[4] = 5; nneut[8] = 7; 
for z = 1:10
   @test ChemicalSpecies(symbols[z]) == ChemicalSpecies(z) == ChemicalSpecies(z, nneut[z], 0)
end

@test ChemicalSpecies(:D) == ChemicalSpecies(1, 1, 0)
@test ChemicalSpecies(:C13) == ChemicalSpecies(6, 7, 0)

@test atomic_number( UInt(8) ) == 8
@test atomic_number( Int16(12) ) == 12

@test "$(ChemicalSpecies(:O))" == "$(ChemicalSpecies(8))" == "O"
@test "$(ChemicalSpecies(8, 8, 0))" == "O16"
@test "$(ChemicalSpecies(:C; n_neutrons=7))" == "C13"

end