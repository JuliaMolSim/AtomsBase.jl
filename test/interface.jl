using AtomsBase
using Test
using Unitful
using UnitfulAtomic
using PeriodicTable

using AtomsBase.Implementation: Atom, FlexibleSystem

@testset "Interface" begin
    box = ([1, 0, 0]u"m", [0, 1, 0]u"m", [0, 0, 1]u"m")
    pbcs = (true, true, false)
    positions = [[0.25, 0.25, 0.25], [0.75, 0.75, 0.75]]u"m"
    elements = [:C, :C]
    atoms = [Atom(elements[i], positions[i]) for i in 1:2]

    @testset "Atoms" begin
        @test position(atoms[1]) == [0.25, 0.25, 0.25]u"m"
        @test velocity(atoms[1]) == [0.0, 0.0, 0.0]u"bohr/s"
        @test atomic_symbol(atoms[1]) == :C
        @test atomic_number(atoms[1]) == 6
        @test atomic_mass(atoms[1])   == 12.011u"u"
        @test element(atoms[1]) == element(:C)
        @test keys(atoms[1]) == (:position, :velocity, :species, :atomic_mass)
        @test get(atoms[1], :blubber, :adidi) == :adidi
    end

    @testset "System" begin
        flexible = FlexibleSystem(atoms, box, pbcs)
        # TODO 
        # fast     = FastSystem(flexible)
        @test length(flexible) == 2
        @test size(flexible)   == (2, )

        @test bounding_box(flexible) == ([1, 0, 0]u"m", [0, 1, 0]u"m", [0, 0, 1]u"m")
        @test periodicity(flexible) == (true, true, false)
        @test n_dimensions(flexible) == 3
        @test position(flexible, :) == [[0.25, 0.25, 0.25], [0.75, 0.75, 0.75]]u"m"
        @test position(flexible, 1) == [0.25, 0.25, 0.25]u"m"
        @test velocity(flexible)[1] == [0.0, 0.0, 0.0]u"bohr/s"
        @test velocity(flexible)[2] == [0.0, 0.0, 0.0]u"bohr/s"
        @test atomic_mass(flexible)   == [12.011, 12.011]u"u"
        @test atomic_number(fast) == [6, 6]
        @test atomic_number(fast, 1) == 6
        @test ismissing(velocity(fast, 2))
        @test atomic_symbol(flexible, 2) == :C
        @test atomic_number(flexible, 2) == 6
        @test atomic_mass(flexible, 1)   == 12.011u"u"

        @test atomkeys(flexible) == (:position, :velocity, :atomic_symbol,
                                     :atomic_number, :atomic_mass)
        @test hasatomkey(flexible, :atomic_number)
        @test flexible[1, :atomic_symbol] == :C
        @test flexible[:, :atomic_symbol] == [:C, :C]

        @test ismissing(velocity(fast))
        @test all(position(fast)      .== position(flexible))
        @test all(atomic_symbol(fast) .== atomic_symbol(flexible))

        # type stability
        get_z_periodicity(syst) = syst[:boundary_conditions][3]
        @test @inferred(BoundaryCondition, get_z_periodicity(flexible)) == DirichletZero()
    end

    # https://github.com/JuliaMolSim/AtomsBase.jl/issues/71
    @testset "Atoms element names" begin
        @test element("silicon").name == "Silicon"
        @test element(:Si).name == "Silicon"
        @test element(14).name == "Silicon"

        @test_throws ArgumentError element("Si")
        @test_throws KeyError element(0)
    end
end
