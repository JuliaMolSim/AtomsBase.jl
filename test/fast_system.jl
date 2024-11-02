using AtomsBase
using Test
using Unitful
using PeriodicTable
using StaticArrays

@testset "Fast system" begin
    box = ([1, 0, 0]u"m", [0, 1, 0]u"m", [0, 0, 1]u"m")
    pbcs = (true, true, false)
    atoms = Atom[:C => [0.25, 0.25, 0.25]u"m",
                 :C => [0.75, 0.75, 0.75]u"m"]
    system = FastSystem(atoms, box, pbcs)

    @test length(system) == 2
    @test size(system)   == (2, )
    @test mass(system, :) == [12.011, 12.011]u"u"
    @test periodicity(system) == pbcs
    @test cell_vectors(system) == box
    @test system[:periodicity] == pbcs
    @test system[:cell_vectors] == box
    @test element(system[1]) == element(:C)
    @test keys(system) == (:cell_vectors, :periodicity)
    @test haskey(system, :periodicity)
    @test system[:periodicity][1] == true
    @test atomkeys(system) == (:position, :species, :mass)
    @test keys(system[1])  == (:position, :species, :mass)
    @test hasatomkey(system, :species)
    @test system[1] == AtomView(system, 1)
    @test system[1:2] == [system[1], system[2]]
    @test system[[2, 1]] == [system[2], system[1]]
    @test system[[1 2; 2 1]] == [system[1] system[2]; system[2] system[1]]
    @test system[:] == [system[1], system[2]]
    @test system[[false, true]] == [AtomView(system, 2)]
    @test atomic_number(system, 1) == 6
    @test atomic_symbol(system, 1:2) == [:C, :C]
    @test atomic_symbol(system, [1, 2]) == [:C, :C]
    @test atomic_symbol(system, :) == [:C, :C]
    @test atomic_number(system, [false, true]) == [6]
    @test system[2][:position] == system[2, :position]
    @test system[2][:position] == [0.75, 0.75, 0.75]u"m"
    @test haskey(system[1], :position)
    @test !haskey(system[1], :abc)
    @test get(system[1], :dagger, 3) == 3

    @test collect(pairs(system)) == [(:cell_vectors => box), (:periodicity => pbcs)]
    @test collect(pairs(system[1])) == [
        :position => position(atoms[1]),
        :species => ChemicalSpecies(:C),
        :mass => mass(atoms[1]),
    ]

    # check type stability
    # TODO: this test needs to be fixed, right now it just tests equality and not 
    #       type stability 
    # get_b_vector(syst) = cell_vectors(syst)[2]
    # @test @inferred(get_b_vector(system)) == SVector{3}([0.0, 1.0, 0.0]u"m")
    # @test @inferred(position(system, 1)) == SVector{3}([0.25, 0.25, 0.25]u"m")
    # @test ismissing(@inferred(velocity(system, 2)))

    # Test AtomView
    for method in (position, mass, species, atomic_number, atomic_symbol)
        @test method(system[1]) == method(system, 1)
        @test method(system[2]) == method(system, 2)
    end
    @test ismissing(velocity(system[1]))
    @test ismissing(velocity(system, :))
    @test n_dimensions(system[1]) == n_dimensions(system)
end
