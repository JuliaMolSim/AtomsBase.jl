using AtomsBase
using Test
using Unitful
using PeriodicTable

@testset "Fast system" begin
    box = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]u"m"
    bcs = [Periodic(), Periodic(), DirichletZero()]
    atoms = Atom[:C => [0.25, 0.25, 0.25]u"m",
                 :C => [0.75, 0.75, 0.75]u"m"]
    system = FastSystem(atoms, box, bcs)

    @test length(system) == 2
    @test size(system)   == (2, )
    @test atomic_mass(system) == [12.011, 12.011]u"u"
    @test boundary_conditions(system) == bcs
    @test bounding_box(system) == box

    @test keys(system) == (:box, :boundary_conditions, :positions, :atomic_symbols, :atomic_numbers, :atomic_masses)
    @test haskey(system, :box)
    @test getkey(system, :atomic_masses) == [12.011, 12.011]u"u"
    @test system[:boundary_conditions] == [Periodic(), Periodic(), DirichletZero()]
    @test system[:positions, 2] == [0.75, 0.75, 0.75]*u"m"


    # Test AtomView
    for method in (position, atomic_mass, atomic_symbol, atomic_number)
        @test method(system[1]) == method(system, 1)
        @test method(system[2]) == method(system, 2)
    end
    @test ismissing(velocity(system[1]))
    @test n_dimensions(system[1]) == n_dimensions(system)
    @test element(system[1])      == elements[:C]
end
