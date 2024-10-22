using AtomsBase
using Unitful
using UnitfulAtomic
using Test

@testset "atomic systems" begin
    @testset "Atom construction" begin
        at2D = Atom(:Si, zeros(2) * u"m", extradata=41)
        @test n_dimensions(at2D) == 2

        at = Atom(:Si, zeros(3) * u"m", extradata=42)

        @test n_dimensions(at) == 3
        @test position(at) == zeros(3) * u"m"
        @test velocity(at) == zeros(3) * u"bohr/s"
        @test element(at)  == element(:Si)
        @test atomic_symbol(at) == :Si
        @test atomic_number(at) == 14
        @test species(at) == ChemicalSpecies(:Si)
        @test haskey(at, :mass)
        @test haskey(at, :species)
        @test haskey(at, :extradata)
        @test at[:extradata] == 42

        @test keys(at) == (:position, :velocity, :species, :mass, :extradata)

        # Test update constructor
        newatom = Atom(at; extradata=43, atomic_number=15)
        @test keys(at) == keys(newatom)
        @test newatom[:extradata] == 43
        @test atomic_number(newatom) == 15

        newatom = Atom(:Si, ones(3)u"m", missing)
        @test iszero(newatom[:velocity])
    end

    @testset "Nothing or zero velocity" begin
        at = Atom(:Si, ones(3) * u"Å"; extradata=42)
        @test velocity(at) == zeros(3)u"Å/s"

        at = Atom(:Si, ones(3) * u"Å", missing; extradata=42)
        @test velocity(at) == zeros(3)u"Å/s"
    end
end
