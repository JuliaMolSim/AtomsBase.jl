using AtomsBase
using Test
using StaticArrays
using Unitful
using PeriodicTable

@testset "AtomsBase.jl" begin
    # Basically transcribing aos_vs_soa example for now...
    box = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]u"m"
    bcs = [Periodic(), Periodic(), DirichletZero()]
    positions = [0.25 0.25 0.25; 0.75 0.75 0.75]u"m"
    elems = [elements[:C], elements[:C]]

    atom1 = StaticAtom(SVector{3}(positions[1,:]),elems[1])
    atom2 = StaticAtom(SVector{3}(positions[2,:]),elems[2])

    aos = FlexibleSystem(box, bcs, [atom1, atom2])
    soa = FastSystem(box, bcs, positions, elems)

    @testset "Atoms" begin
        @test position(atom1) == [0.25, 0.25, 0.25]u"m"
        @test ismissing(velocity(atom1))
        @test species(atom1) == elements[:C]
        @test atomic_symbol(atom1) == "C"
        @test atomic_number(atom1) == 6
        @test atomic_mass(atom1) == 12.011u"u"
        @test atomic_property(atom1, :shells) == [2, 4]
    end

    @testset "System" begin
        @test bounding_box(aos) == [[1, 0, 0], [0, 1, 0], [0, 0, 1]]u"m"
        @test boundary_conditions(aos) == [Periodic(), Periodic(), DirichletZero()]
        @test is_periodic(aos) == [1, 1, 0]
        @test n_dimensions(aos) == 3
        @test position(aos) == [[0.25, 0.25, 0.25], [0.75, 0.75, 0.75]]u"m"
        @test position(aos, 1) == [0.25, 0.25, 0.25]u"m"
        @test all(ismissing.(velocity(aos)))
        @test species(aos) == [elements[:C], elements[:C]]
        @test species(soa, 1) == elements[:C]
        @test all(soa .== aos)
    end

end
