using AtomsBase
using Test
using Unitful
using PeriodicTable
using StaticArrays

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
    @test system[:boundary_conditions] == bcs
    @test system[:bounding_box] == box
    @test !isinfinite(system)
    @test element(system[1]) == element(:C)
    @test keys(system) == (:bounding_box, :boundary_conditions)
    @test haskey(system, :boundary_conditions)
    @test system[:boundary_conditions][1] == Periodic()
    @test atomkeys(system) == (:position, :atomic_symbol, :atomic_number, :atomic_mass)
    @test keys(system[1])  == (:position, :atomic_symbol, :atomic_number, :atomic_mass)
    @test hasatomkey(system, :atomic_symbol)
    @test system[1, :atomic_number] == 6
    @test system[:, :atomic_symbol] == [:C, :C]
    @test system[2][:position] == system[2, :position]
    @test system[2][:position] == [0.75, 0.75, 0.75]u"m"
    @test haskey(system[1], :position)
    @test !haskey(system[1], :abc)
    @test get(system[1], :dagger, 3) == 3

    @test collect(pairs(system)) == [(:bounding_box => box), (:boundary_conditions => bcs)]
    @test collect(pairs(system[1])) == [
        :position => position(atoms[1]),
        :atomic_symbol => :C,
        :atomic_number => 6,
        :atomic_mass => atomic_mass(atoms[1]),
    ]

    # check type stability
    get_b_vector(syst) = bounding_box(syst)[2]
    @test @inferred(get_b_vector(system)) === SVector{3}([0.0, 1.0, 0.0]u"m")
    @test @inferred(position(system, 1)) === SVector{3}([0.25, 0.25, 0.25]u"m")
    @test ismissing(@inferred(velocity(system, 2)))

    # Test AtomView
    for method in (position, atomic_mass, atomic_symbol, atomic_number)
        @test method(system[1]) == method(system, 1)
        @test method(system[2]) == method(system, 2)
    end
    @test ismissing(velocity(system[1]))
    @test n_dimensions(system[1]) == n_dimensions(system)
end
