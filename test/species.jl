
using AtomsBase
using Unitful
using UnitfulAtomic
using Test

##

@testset "ChemicalSpecies" begin 

symbols = [:H, :He, :Li, :Be, :B, :C, :N, :O, :F, :Ne, 
          :Na, :Mg, :Al, :Si, :P, :S, :Cl, :Ar, :K, :Ca]

# https://thechemicalelements.com/protons-neutrons-electrons-of-elements/
n_neut =  [0, 2, 4, 5, 6, 6, 7, 8, 10, 10, 
           12, 12, 14, 14, 16, 16, 18, 22, 20, 20] 

for z = 1:10
   @test ChemicalSpecies(symbols[z]) == ChemicalSpecies(z) == ChemicalSpecies(z, n_neut[z], 0)
end

@test ChemicalSpecies(:D) == ChemicalSpecies(1, 1, 0)
@test ChemicalSpecies(:C13) == ChemicalSpecies(6, 7, 0)

@test atomic_number( UInt(8) ) == 8
@test atomic_number( Int16(12) ) == 12

@test "$(ChemicalSpecies(:O))" == "$(ChemicalSpecies(8))" == "O"
@test "$(ChemicalSpecies(8, 8, 0))" == "O16"
@test "$(ChemicalSpecies(:C; n_neutrons=6))" == "C12"
@test "$(ChemicalSpecies(:C; n_neutrons=7))" == "C13"


@test ChemicalSpecies(:C13) == ChemicalSpecies(:C)
@test ChemicalSpecies(:C12) != ChemicalSpecies(:C13)
@test ChemicalSpecies(:C; atomic_name=:MyC) == ChemicalSpecies(:C)
@test ChemicalSpecies(:C12; atomic_name=:MyC) == ChemicalSpecies(:C12)
@test ChemicalSpecies(:C; atomic_name=:MyC) != ChemicalSpecies(:C12)
@test ChemicalSpecies(:C12; atomic_name=:MyC) == ChemicalSpecies(:C)
@test ChemicalSpecies(:C; atomic_name=:MyC) == ChemicalSpecies(:C12; atomic_name=:MyC)
@test ChemicalSpecies(:D) != ChemicalSpecies(:T)
@test ChemicalSpecies(:H) == ChemicalSpecies(:D)
@test ChemicalSpecies(:H) == ChemicalSpecies(:T)
@test ChemicalSpecies(:H1) != ChemicalSpecies(:D)
@test ChemicalSpecies(:H1) == ChemicalSpecies(1; n_neutrons=0)

@test mass(ChemicalSpecies(:C)) != mass(ChemicalSpecies(:C12))
@test mass(ChemicalSpecies(:C)) != mass(ChemicalSpecies(:C13))
@test mass(ChemicalSpecies(:C12)) != mass(ChemicalSpecies(:C13))

@test atomic_name(ChemicalSpecies(:C)) == atomic_symbol(ChemicalSpecies(:C))
@test atomic_name(ChemicalSpecies(:C; atomic_name=:MyC)) == :MyC

tmp = ChemicalSpecies(:C12; atomic_name=:MyC)
@test atomic_name(tmp) != atomic_symbol(tmp)

end
