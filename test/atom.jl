using AtomsBase
using Unitful
using Test


@testset "atomic systems" begin
    @testset "Atom construction" begin
        at2D = Atom(:Si, zeros(2) * u"m", extradata=41)
        @test n_dimensions(at2D) == 2

        at = Atom(:Si, zeros(3) * u"m", extradata=42)

        @test n_dimensions(at) == 3
        @test position(at) == zeros(3) * u"m"
        @test velocity(at) == zeros(3) * u"bohr/s"
        @test element(at)  == element(:Si)
        @test at.atomic_symbol == :Si
        @test at.atomic_number == 14
        @test hasproperty(at, :atomic_mass)
        @test hasproperty(at, :atomic_symbol)
        @test hasproperty(at, :atomic_number)
        @test hasproperty(at, :extradata)
        @test at.extradata == 42

        @test propertynames(at) == (:position, :velocity, :atomic_symbol,
                                    :atomic_number, :atomic_mass, :extradata)

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
        dic = Dict{String, Any}("extradata_dic"=>"44")
        atoms = [:Si => [0.0, 1.0, 1.5]u"Å",
                 :C  => [0.0, 0.8, 1.7]u"Å",
                 Atom(:H, zeros(3) * u"Å", ones(3) * u"bohr/s")]
        system = atomic_system(atoms, box, bcs, extradata=45; dic)
        @test length(system) == 3
        @test atomic_symbol(system) == [:Si, :C, :H]
        @test boundary_conditions(system) == [Periodic(), DirichletZero(), DirichletZero()]
        @test position(system) == [[0.0, 1.0, 1.5], [0.0, 0.8, 1.7], [0.0, 0.0, 0.0]]u"Å"
        @test velocity(system) == [[0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [1.0, 1.0, 1.0]]u"bohr/s"
        @test system.extradata == 45
        @test system.dic["extradata_dic"] == "44"

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
        dic = Dict{String, Any}("extradata_dic"=>"47")
        system = isolated_system([:Si => [0.0, 1.0, 1.5]u"Å",
                                  :C  => [0.0, 0.8, 1.7]u"Å",
                                  Atom(:H, zeros(3) * u"Å")], extradata=46; dic)
        @test length(system) == 3
        @test atomic_symbol(system) == [:Si, :C, :H]
        @test boundary_conditions(system) == [DirichletZero(), DirichletZero(), DirichletZero()]
        @test position(system) == [[0.0, 1.0, 1.5], [0.0, 0.8, 1.7], [0.0, 0.0, 0.0]]u"Å"
        @test velocity(system) == [[0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0]]u"bohr/s"
        @test bounding_box(system) == infinite_box(3)
        @test system.extradata == 46
        @test system.dic["extradata_dic"] == "47"
    end

    @testset "periodic_system" begin
        box = [[10, 0.0, 0.0], [0.0, 5, 0.0], [0.0, 0.0, 7]]u"Å"
        dic = Dict{String, Any}("extradata_dic"=>"49")
        atoms = [:Si => [0.0, -0.125, 0.0],
                 :C  => [0.125, 0.0, 0.0],
                 Atom(:H, zeros(3) * u"Å")]
        system = periodic_system(atoms, box, extradata=48; fractional=true, dic)

        @test length(system) == 3
        @test atomic_symbol(system) == [:Si, :C, :H]
        @test boundary_conditions(system) == [Periodic(), Periodic(), Periodic()]
        @test position(system) == [[0.0, -0.625, 0.0], [1.25, 0.0, 0.0], [0.0, 0.0, 0.0]]u"Å"
        @test system.extradata == 48
        @test system.dic["extradata_dic"] == "49"
    end


    @testset "no stackoverflow" begin
        box = [[10, 0.0, 0.0], [0.0, 5, 0.0], [0.0, 0.0, 7]]u"Å"
        atoms = Any[:Si => [0.0, -0.125, 0.0],
                    :C  => [0.125, 0.0, 0.0],
                    Atom(:H, zeros(3) * u"Å")]
        system = periodic_system(atoms, box; fractional=true)
        @test length(system) == 3

        system = isolated_system(Any[:Si => [0.0, 1.0, 1.5]u"Å",
                                     :C  => [0.0, 0.8, 1.7]u"Å",
                                     Atom(:H, zeros(3) * u"Å")])
        @test length(system) == 3
    end
end
