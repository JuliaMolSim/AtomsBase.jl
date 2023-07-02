using AtomsBase
using Test
using Unitful
using UnitfulAtomic

@testset "Chemical formula with symbols" begin
    @test chemical_formula([:H])                  == "H"
    @test chemical_formula([:H, :H])              == "H₂"
    @test chemical_formula([:H, :O, :H])          == "H₂O"
    @test chemical_formula([:O, :H, :O, :H])      == "H₂O₂"
    @test chemical_formula([:Ga, :N, :O, :H, :H]) == "GaH₂NO"
end

@testset "Chemical formula with system" begin
    lattice     = [12u"bohr" * rand(3) for _ in 1:3]
    atoms       = [Atom(6, randn(3)u"Å"; atomic_symbol=:C1),
                   Atom(6, randn(3)u"Å"; atomic_symbol=:C2),
                   Atom(1, randn(3)u"Å"; atomic_symbol=:D),
                   Atom(1, randn(3)u"Å"; atomic_symbol=:D),
                   Atom(1, randn(3)u"Å"; atomic_symbol=:D),
                  ]
    system      = periodic_system(atoms, lattice)
    @test atomic_symbol(system) == [:C1, :C2, :D, :D, :D]
    @test chemical_formula(system) == "C₂H₃"
end
