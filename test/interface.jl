using AtomsBase
using Test
using Unitful
using UnitfulAtomic
using PeriodicTable

@testset "Interface" begin
    box = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]u"m"
    bcs = [Periodic(), Periodic(), OpenBC()]
    positions = [[0.25, 0.25, 0.25], [0.75, 0.75, 0.75]]u"m"
    elements = [:C, :C]
    atoms = [Atom(elements[i], positions[i]) for i in 1:2]
    fatoms = [ FastAtom(elements[i], positions[i]) for i in 1:2 ] 

    @testset "Atoms" begin
        @test position(atoms[1]) == [0.25, 0.25, 0.25]u"m"
        @test position(fatoms[1]) == [0.25, 0.25, 0.25]u"m"
        @test velocity(atoms[1]) == [0.0, 0.0, 0.0]u"bohr/s"
        @test atomic_symbol(atoms[1]) == :C
        @test atomic_symbol(fatoms[1]) == :C
        @test atomic_number(atoms[1]) == 6
        @test atomic_number(fatoms[1]) == 6
        @test atomic_mass(atoms[1])   == 12.011u"u"
        @test atomic_mass(fatoms[1])   == 12.011u"u"
        @test element(atoms[1]) == element(:C)
        @test element(fatoms[1]) == element(:C)
        @test atoms[1][atomic_number] == 6
        @test keys(atoms[1]) == (:position, :velocity, :chemical_element, 
                                 :atomic_mass)
        @test get(atoms[1], :blubber, :adidi) == :adidi
        @test get(fatoms[1], :blubber, :adidi) == :adidi

        for f in (velocity, position, atomic_mass, atomic_symbol, atomic_number, element)
            @test atoms[1][f] === f(atoms[1])
            @test fatoms[1][f] === f(fatoms[1])
        end
    end

    @testset "System" begin
        flexible = FlexibleSystem(atoms, box, bcs)
        fast    = FastSystem(flexible)
        fast2   = FastSystem(atoms, box, bcs)
        @test fast.cell == fast2.cell
        @test fast.position == fast2.position
        @test length(flexible) == 2
        @test size(flexible)   == (2, )

        @test all(bounding_box(flexible) .== [[1, 0, 0], [0, 1, 0], [0, 0, 1]]u"m")
        @test all(boundary_conditions(flexible) .== [Periodic(), Periodic(), OpenBC()])
        @test periodicity(flexible) == (true, true, false)
        @test !all(isinfinite(flexible))
        @test any(isinfinite(flexible))
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
        @test atomic_mass(flexible, 1)   == PeriodicTable.elements[6].atomic_mass

        @test atomkeys(flexible) == (:position, :velocity, :chemical_element,
                                     :atomic_mass)
        @test hasatomkey(flexible, :chemical_element)
        @test flexible[1, atomic_symbol] == :C
        @test all(flexible[:, atomic_symbol] .== [:C, :C])
        @test atomic_symbol(flexible[1]) == :C
        @test atomic_symbol.(flexible[:]) == [:C, :C] 

        @test ismissing(velocity(fast))
        @test all(position(fast)      .== position(flexible))
        @test all(atomic_symbol(fast) .== atomic_symbol(flexible))

        # type stability
        get_z_periodicity(syst) = syst[:boundary_conditions][3]
        @test @inferred(BoundaryCondition, get_z_periodicity(flexible)) == OpenBC()
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
