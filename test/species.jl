
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
@test ChemicalSpecies(:H) == :H
@test ChemicalSpecies(:D) == :D
@test ChemicalSpecies(:T) == :T
@test ChemicalSpecies(:X) == :X
@test ChemicalSpecies(:U238) == :U238
@test ChemicalSpecies(:Cl35) == :Cl35
@test ChemicalSpecies(:He3) == :He3

@test_throws ArgumentError ChemicalSpecies(:C; atom_name=:MyLongC)
@test_throws ArgumentError ChemicalSpecies(:U2389)
@test_throws ArgumentError ChemicalSpecies(:Q)
@test_throws ArgumentError ChemicalSpecies(:Q23)

@test ChemicalSpecies(:H) != ChemicalSpecies(:C)
@test ChemicalSpecies(:C13) == ChemicalSpecies(:C) 
@test ChemicalSpecies(:C12) != ChemicalSpecies(:C13)
@test ChemicalSpecies(:C; atom_name=:MyC) == ChemicalSpecies(:C)
@test ChemicalSpecies(:C12; atom_name=:MyC) == ChemicalSpecies(:C12)
@test ChemicalSpecies(:C; atom_name=:MyC) != ChemicalSpecies(:C12)
@test ChemicalSpecies(:C12; atom_name=:MyC) == ChemicalSpecies(:C)
@test ChemicalSpecies(:C; atom_name=:MyC) == ChemicalSpecies(:C12; atom_name=:MyC)
@test ChemicalSpecies(:C; atom_name=:MyC) != ChemicalSpecies(:C; atom_name=:noC)
@test ChemicalSpecies(:D) != ChemicalSpecies(:T)
@test ChemicalSpecies(:H) == ChemicalSpecies(:D)
@test ChemicalSpecies(:H) == ChemicalSpecies(:T)
@test ChemicalSpecies(:H1) != ChemicalSpecies(:D)
@test ChemicalSpecies(:H1) == ChemicalSpecies(1; n_neutrons=0)

@test mass(ChemicalSpecies(:C)) != mass(ChemicalSpecies(:C12))
@test mass(ChemicalSpecies(:C)) != mass(ChemicalSpecies(:C13))
@test mass(ChemicalSpecies(:C12)) != mass(ChemicalSpecies(:C13))

@test atom_name(ChemicalSpecies(:C)) == Symbol(atomic_symbol(ChemicalSpecies(:C)))
@test atom_name(ChemicalSpecies(:C; atom_name=:MyC)) == :MyC

tmp = ChemicalSpecies(:C12; atom_name=:MyC)
@test atom_name(tmp) != atomic_symbol(tmp)

@test mass(ChemicalSpecies(:C)) != mass(ChemicalSpecies(:C12))
@test mass(ChemicalSpecies(:C12)) != mass(ChemicalSpecies(:C13))
@test mass(ChemicalSpecies(:X)) == 0.0u"u"
@test ismissing( mass(ChemicalSpecies(:H31)) )

@test element_symbol(ChemicalSpecies(:C)) == :C
@test element_symbol(ChemicalSpecies(:C13)) == :C

@testset "ChemicalSpecies in Atom and FastSystem" begin
   box = ([1, 0, 0]u"m", [0, 1, 0]u"m", [0, 0, 1]u"m")
   pbcs = (true, true, false)
   atoms = Atom[ChemicalSpecies(:C; atom_name=:MyC) => [0.25, 0.25, 0.25]u"m",
               :C12 => [0.75, 0.75, 0.75]u"m"]
   system = FastSystem(atoms, box, pbcs)

   @test atom_name(atoms[1]) == :MyC
   @test atom_name(atoms[2]) == :C12
   @test atomic_symbol(atoms[1]) == :C
   @test atomic_symbol(atoms[2]) == :C12

   @test mass(atoms[1]) == mass(ChemicalSpecies(:C))
   @test mass(atoms[2]) == mass(ChemicalSpecies(:C12))

   @test atom_name(system, 1) == :MyC
   @test atom_name(system, 2) == :C12
   @test atomic_symbol(system, 1) == :C
   @test atomic_symbol(system, 2) == :C12

   @test atom_name(system[1]) == :MyC
   @test atom_name(system[2]) == :C12
   @test atomic_symbol(system[1]) == :C
   @test atomic_symbol(system[2]) == :C12

   @test mass(system, 1) == mass(ChemicalSpecies(:C))
   @test mass(system, 2) == mass(ChemicalSpecies(:C12))

   @test element_symbol(system, 1) == :C
   @test element_symbol(system, 2) == :C
   @test element_symbol(system, :) == [:C, :C]
end

end
