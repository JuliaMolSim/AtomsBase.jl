using AtomsBase
using Unitful
using UnitfulAtomic
using Test

##

@testset "ChemicalSpecies" begin
    @testset "Neutron determination" begin
        symbols = [:H, :He, :Li, :Be, :B, :C, :N, :O, :F, :Ne,
                  :Na, :Mg, :Al, :Si, :P, :S, :Cl, :Ar, :K, :Ca]

        # https://thechemicalelements.com/protons-neutrons-electrons-of-elements/
        n_neut =  [0, 2, 4, 5, 6, 6, 7, 8, 10, 10,
                   12, 12, 14, 14, 16, 16, 18, 22, 20, 20]

        for z = 1:10
           @test ChemicalSpecies(symbols[z]) == ChemicalSpecies(z)
           @test ChemicalSpecies(z) == ChemicalSpecies(z, n_neut[z], 0)
        end

        @test ChemicalSpecies(:D) == ChemicalSpecies(1, 1, 0)
        @test ChemicalSpecies(:C13) == ChemicalSpecies(6, 7, 0)
    end

    @testset "Printing" begin
        @test "$(ChemicalSpecies(:O))" == "$(ChemicalSpecies(8))" == "O"
        @test "$(ChemicalSpecies(8, 8, 0))" == "O"
        @test "$(ChemicalSpecies(:C; n_neutrons=6))" == "C"
        @test "$(ChemicalSpecies(:C; n_neutrons=7))" == "C13"
    end

    @testset "Special cases" begin
        # Test a few special cases that come up in the wild
        x = ChemicalSpecies(0)
        @test x.n_neutrons == 0
        @test atomic_number(x) == 0
        @test mass(x) == 0u"u"

        @test x = ChemicalSpecies(:X)
    end

    @test atomic_number( UInt(8) ) == 8
    @test atomic_number( Int16(12) ) == 12
end
