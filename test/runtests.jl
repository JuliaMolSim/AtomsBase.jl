using AtomsBase
using Test
using StaticArrays
using Unitful
using PeriodicTable

@testset "AtomsBase.jl" begin
    # Basically transcribing aos_vs_soa example for now...
    box = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]u"m"
    bcs = [Periodic(), Periodic(), DirichletZero()]
    positions = [[0.25, 0.25, 0.25], [0.75, 0.75, 0.75]]u"m"
    elements = [:C, :C]

    atom1 = Atom(elements[1], positions[1])
    atom2 = Atom(elements[2], positions[2])
    aos = FlexibleSystem(box, [atom1, atom2], bcs)
    soa = FastSystem(box, elements, positions, bcs)

    @testset "Atoms" begin
        @test position(atom1) == [0.25, 0.25, 0.25]u"m"
        @test ismissing(velocity(atom1))
        @test element(atom1) == PeriodicTable.elements[:C]
        @test atomic_symbol(atom1) == :C
        @test atomic_number(atom1) == 6
        @test atomic_mass(atom1)   == 12.011u"u"
    end

    @testset "System" begin
        @test bounding_box(aos) == [[1, 0, 0], [0, 1, 0], [0, 0, 1]]u"m"
        @test boundary_conditions(aos) == [Periodic(), Periodic(), DirichletZero()]
        @test periodicity(aos) == [1, 1, 0]
        @test n_dimensions(aos) == 3
        @test position(aos) == [[0.25, 0.25, 0.25], [0.75, 0.75, 0.75]]u"m"
        @test position(aos, 1) == [0.25, 0.25, 0.25]u"m"
        @test all(ismissing, velocity(aos))
        @test atomic_mass(aos)   == [12.011, 12.011]u"u"
        @test atomic_number(soa) == [6, 6]
        @test atomic_number(soa, 1) == 6
        @test atomic_symbol(aos, 2) == :C

        @test all(position(soa)      .== position(aos))
        @test all(atomic_symbol(soa) .== atomic_symbol(aos))
    end
end
