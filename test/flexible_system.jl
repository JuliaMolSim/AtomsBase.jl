using AtomsBase
using Unitful
using UnitfulAtomic
using Test

@testset "Fast system" begin
    box = tuple([[10, 0.0, 0.0], [0.0, 5, 0.0], [0.0, 0.0, 7]]u"Å" ...)
    bcs = [Periodic(), DirichletZero(), DirichletZero()]
    dic = Dict{String, Any}("extradata_dic"=>"44")
    atoms = [:Si => [0.0, 1.0, 1.5]u"Å",
             :C  => [0.0, 0.8, 1.7]u"Å",
             Atom(:H, zeros(3) * u"Å", ones(3) * u"bohr/s"; dat=3.0)]
    system = FlexibleSystem(convert.(Atoms, atoms), box, bcs; extra_data=45, kwargs...)
    @test length(system) == 3
    @test atomic_symbol(system) == [:Si, :C, :H]
    @test boundary_conditions(system) == [Periodic(), DirichletZero(), DirichletZero()]
    @test position(system) == [[0.0, 1.0, 1.5], [0.0, 0.8, 1.7], [0.0, 0.0, 0.0]]u"Å"
    @test velocity(system) == [[0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [1.0, 1.0, 1.0]]u"bohr/s"
    @test system[:extradata] == 45
    @test system[:dic]["extradata_dic"] == "44"
    @test system[3] == atoms[3]
    @test system[1:2] == [system[1], system[2]]
    @test system[[1, 3]] == [system[1], system[3]]
    @test system[[1 3; 2 1]] == [system[1] system[3]; system[2] system[1]]
    @test system[:] == [system[1], system[2], system[3]]
    @test system[[false, false, true]] == [system[3]]
    @test system[3, :dat] == 3.0
    @test system[2, :atomic_symbol] == :C
    @test system[1:2, :atomic_number] == [14, 6]
    @test system[[1, 3], :atomic_number] == [14, 1]
    @test system[:, :atomic_number] == [14, 6, 1]
    @test system[[false, true, true], :atomic_symbol] == [:C, :H]
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
