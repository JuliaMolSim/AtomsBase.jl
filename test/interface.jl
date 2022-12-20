using AtomsBase
using Test
using Unitful
using UnitfulAtomic
using PeriodicTable

@testset "Interface" begin
    box = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]u"m"
    bcs = [Periodic(), Periodic(), DirichletZero()]
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
    end

    @testset "System" begin
        flexible = FlexibleSystem(atoms, box, bcs)
        fast     = FastSystem(flexible)
        @test length(flexible) == 2
        @test size(flexible)   == (2, )

        @test bounding_box(flexible) == [[1, 0, 0], [0, 1, 0], [0, 0, 1]]u"m"
        @test boundary_conditions(flexible) == [Periodic(), Periodic(), DirichletZero()]
        @test periodicity(flexible) == [1, 1, 0]
        @test !isinfinite(flexible)
        @test n_dimensions(flexible) == 3
        @test position(flexible) == [[0.25, 0.25, 0.25], [0.75, 0.75, 0.75]]u"m"
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

        @test ismissing(velocity(fast))
        @test all(position(fast)      .== position(flexible))
        @test all(atomic_symbol(fast) .== atomic_symbol(flexible))
    end
end
