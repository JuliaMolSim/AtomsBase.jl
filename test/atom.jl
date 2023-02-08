using AtomsBase
using Unitful
using UnitfulAtomic
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
        @test atomic_symbol(at) == :Si
        @test atomic_number(at) == 14
        @test at[:atomic_symbol] == :Si
        @test at[:atomic_number] == 14
        @test haskey(at, :atomic_mass)
        @test haskey(at, :atomic_symbol)
        @test haskey(at, :atomic_number)
        @test haskey(at, :extradata)
        @test at[:extradata] == 42

        @test keys(at) == (:position, :velocity, :atomic_symbol,
                           :atomic_number, :atomic_mass, :extradata)

        # Test update constructor
        newatom = Atom(at; extradata=43, atomic_number=15)
        @test keys(at) == keys(newatom)
        @test newatom[:extradata] == 43
        @test newatom[:atomic_number] == 15

        newatom = Atom(at; extradata=43, atomic_number=15)
        @test keys(at) == keys(newatom)
        @test newatom[:extradata] == 43
        @test newatom[:atomic_number] == 15

        newatom = Atom(:Si, ones(3)u"m", missing)
        @test iszero(newatom[:velocity])
    end

    @testset "flexible atomic systems" begin
        box = [[10, 0.0, 0.0], [0.0, 5, 0.0], [0.0, 0.0, 7]]u"Å"
        bcs = [Periodic(), DirichletZero(), DirichletZero()]
        dic = Dict{String, Any}("extradata_dic"=>"44")
        atoms = [:Si => [0.0, 1.0, 1.5]u"Å",
                 :C  => [0.0, 0.8, 1.7]u"Å",
                 Atom(:H, zeros(3) * u"Å", ones(3) * u"bohr/s"; dat=3.0)]
        system = atomic_system(atoms, box, bcs, extradata=45; dic)
        @test length(system) == 3
        @test atomic_symbol(system) == [:Si, :C, :H]
        @test boundary_conditions(system) == [Periodic(), DirichletZero(), DirichletZero()]
        @test position(system) == [[0.0, 1.0, 1.5], [0.0, 0.8, 1.7], [0.0, 0.0, 0.0]]u"Å"
        @test velocity(system) == [[0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [1.0, 1.0, 1.0]]u"bohr/s"
        @test system[:extradata] == 45
        @test system[:dic]["extradata_dic"] == "44"
        @test system[3] == atoms[3]
        @test system[1:2] == [system[1], system[2]]
        @test system[[1,3]] == [system[1], system[3]]
        @test system[:] == [system[1], system[2], system[3]]
        @test system[[false,false,true]] == [system[3]]
        @test system[3, :dat] == 3.0
        @test system[2, :atomic_symbol] == :C
        @test system[1:2, :atomic_number] == [14, 6]
        @test system[[1,3], :atomic_number] == [14, 1]
        @test system[:, :atomic_number] == [14, 6, 1]
        @test system[[false,true,true], :atomic_symbol] == [:C,:H]
        @test atomkeys(system) == (:position, :velocity, :atomic_symbol,
                                   :atomic_number, :atomic_mass)
        @test hasatomkey(system, :atomic_mass)
        @test !hasatomkey(system, :blubber)
        @test get(system, :blubber, :adidi) == :adidi

        @test collect(pairs(system)) == [
            :bounding_box => box, :boundary_conditions => bcs,
            :extradata => 45, :dic => dic
        ]
        @test collect(pairs(system[1])) == [
            :position => [0.0, 1.0, 1.5]u"Å",
            :velocity => zeros(3)u"Å/s",
            :atomic_symbol => :Si,
            :atomic_number => 14,
            :atomic_mass => AtomsBase.element(:Si).atomic_mass,
        ]

        # Test update constructor
        newatoms  = [system[1], system[2]]
        newsystem = AbstractSystem(system; atoms=newatoms,
                                   boundary_conditions=[Periodic(), Periodic(), Periodic()])
        @test newsystem isa FlexibleSystem
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
        @test system[:extradata] == 46
        @test system[:dic]["extradata_dic"] == "47"
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
        @test system[:extradata] == 48
        @test system[:dic]["extradata_dic"] == "49"
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

    @testset "Nothing or zero velocity" begin
        at = Atom(:Si, ones(3) * u"Å"; extradata=42)
        @test velocity(at) == zeros(3)u"Å/s"

        at = Atom(:Si, ones(3) * u"Å", missing; extradata=42)
        @test velocity(at) == zeros(3)u"Å/s"
    end
end
