using AtomsBase
using Test
using Unitful
using UnitfulAtomic
using AtomsBase.Implementation

@testset "Chemical formula with symbols" begin
    @test chemical_formula([:H])                  == "H"
    @test chemical_formula([:H, :H])              == "H₂"
    @test chemical_formula([:H, :O, :H])          == "H₂O"
    @test chemical_formula([:O, :H, :O, :H])      == "H₂O₂"
    @test chemical_formula([:Ga, :N, :O, :H, :H]) == "GaH₂NO"
end


@testset "Chemical Species" begin 
    s = ChemicalSpecies(:C)
    @test atomic_number(s) == 6
    @test atomic_symbol(s) == :C
    s1 = ChemicalSpecies(:C; nneutrons=7)
    s2 = ChemicalSpecies(:C13) 
    @test s1 == s2
    @test atomic_number(s1) == 6
    @test atomic_symbol(s1) == :C13
    s3 = ChemicalSpecies(:D) 

end 

@testset "Chemical formula with system" begin
    lattice     = tuple([12u"bohr" * rand(3) for _ in 1:3]...)
    atoms       = [Atom(:C13, randn(3)u"Å"), #; atomic_symbol=:C1),
                   Atom(:C14, randn(3)u"Å"), #; atomic_symbol=:C2),
                   Atom(:D, randn(3)u"Å" ),  #; atomic_symbol=:D),
                   Atom(:D, randn(3)u"Å" ),  #; atomic_symbol=:D),
                   Atom(:D, randn(3)u"Å" ),  #; atomic_symbol=:D),
                  ]
    # system = periodic_system(atoms, lattice)
    system = FlexibleSystem(atoms, lattice, true)
    @test species(system, :) == ChemicalSpecies.([:C13, :C14, :D, :D, :D])
    @test element_symbol(system, :) == [:C, :C, :H, :H, :H]
    @test chemical_formula(system) == "C₂H₃"
end


