using AtomsBase
using Unitful
using Test


@testset "atomic systems" begin
    @testset "Atom construction" begin
        at = Atom(:Si, zeros(3) * u"m", extradata=42)

        @test n_dimensions(at) == 3
        @test position(at) == zeros(3) * u"m"
        @test at.atomic_symbol == :Si
        @test at.atomic_number == 14
        @test hasproperty(at, :atomic_mass)
        @test hasproperty(at, :atomic_symbol)
        @test hasproperty(at, :atomic_number)
        @test hasproperty(at, :extradata)
        @test at.extradata == 42

        @test propertynames(at) == (:position, :atomic_symbol, :atomic_number,
                                    :atomic_mass, :extradata)

        # Test update constructor
        newatom = Atom(at; extradata=43, atomic_number=15)
        @test propertynames(at) == propertynames(newatom)
        @test newatom.extradata == 43
        @test newatom.atomic_number == 15

        newatom = Atom(; atom=at, extradata=43, atomic_number=15)
        @test propertynames(at) == propertynames(newatom)
        @test newatom.extradata == 43
        @test newatom.atomic_number == 15
    end

    @testset "flexible atomic systems" begin
        box = [[10, 0.0, 0.0], [0.0, 5, 0.0], [0.0, 0.0, 7]]u"Å"
        bcs = [Periodic(), DirichletZero(), DirichletZero()]
        atoms = [:Si => [0.0, 1.0, 1.5]u"Å",
                 :C  => [0.0, 0.8, 1.7]u"Å",
                 Atom(:H, zeros(3) * u"Å")]
        system = atomic_system(atoms, box, bcs)
        @test length(system) == 3
        @test atomic_symbol(system) == [:Si, :C, :H]
        @test boundary_conditions(system) == [Periodic(), DirichletZero(), DirichletZero()]
        @test position(system) == [[0.0, 1.0, 1.5], [0.0, 0.8, 1.7], [0.0, 0.0, 0.0]]u"Å"

        # Test update constructor
        newatoms  = [system[1], system[2]]
        newsystem = FlexibleSystem(system; atoms=newatoms,
                                   boundary_conditions=[Periodic(), Periodic(), Periodic()])
        @test length(newsystem) == 2
        @test atomic_symbol(newsystem) == [:Si, :C]
        @test boundary_conditions(newsystem) == [Periodic(), Periodic(), Periodic()]
        @test position(newsystem) == [[0.0, 1.0, 1.5], [0.0, 0.8, 1.7]]u"Å"
    end

    @testset "isolated_system" begin
        system = isolated_system([:Si => [0.0, 1.0, 1.5]u"Å",
                                  :C  => [0.0, 0.8, 1.7]u"Å",
                                  Atom(:H, zeros(3) * u"Å")])
        @test length(system) == 3
        @test atomic_symbol(system) == [:Si, :C, :H]
        @test boundary_conditions(system) == [DirichletZero(), DirichletZero(), DirichletZero()]
        @test position(system) == [[0.0, 1.0, 1.5], [0.0, 0.8, 1.7], [0.0, 0.0, 0.0]]u"Å"
        @test bounding_box(system) == infinite_box(3)
    end

    @testset "periodic_system" begin
        box = [[10, 0.0, 0.0], [0.0, 5, 0.0], [0.0, 0.0, 7]]u"Å"
        atoms = [:Si => [0.0, -0.125, 0.0],
                 :C  => [0.125, 0.0, 0.0],
                 Atom(:H, zeros(3) * u"Å")]
        system = periodic_system(atoms, box; fractional=true)

        @test length(system) == 3
        @test atomic_symbol(system) == [:Si, :C, :H]
        @test boundary_conditions(system) == [Periodic(), Periodic(), Periodic()]
        @test position(system) == [[0.0, -0.625, 0.0], [1.25, 0.0, 0.0], [0.0, 0.0, 0.0]]u"Å"
    end
end
