using AtomsBase
using Unitful
using UnitfulAtomic
using Test

@testset "Flexible system" begin
    box = tuple([[10, 0.0, 0.0], [0.0, 5, 0.0], [0.0, 0.0, 7]]u"Å" ...)
    pbcs = (true, false, false)
    dic = Dict{String, Any}("extradata_dic"=>"44")
    atoms = [:Si => [0.0, 1.0, 1.5]u"Å",
             :C  => [0.0, 0.8, 1.7]u"Å",
             Atom(:H, zeros(3) * u"Å", ones(3) * u"bohr/s"; dat=3.0)]
    system = FlexibleSystem(convert.(Atom, atoms), box, pbcs; extradata=45, dic)
    @test length(system) == 3
    @test species(system, :) == ChemicalSpecies.([:Si, :C, :H])
    @test periodicity(system) == (true, false, false)
    @test position(system, :) == [[0.0, 1.0, 1.5], [0.0, 0.8, 1.7], [0.0, 0.0, 0.0]]u"Å"
    @test velocity(system, :) == [[0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [1.0, 1.0, 1.0]]u"bohr/s"
    @test system[:extradata] == 45
    @test system[:dic]["extradata_dic"] == "44"
    @test system[3] == atoms[3]
    @test system[1:2] == [system[1], system[2]]
    @test system[[1, 3]] == [system[1], system[3]]
    @test system[[1 3; 2 1]] == [system[1] system[3]; system[2] system[1]]
    @test system[:] == [system[1], system[2], system[3]]
    @test system[[false, false, true]] == [system[3]]
    @test system[3, :dat] == 3.0
    @test system[2, :species] == ChemicalSpecies(:C)
    @test system[1:2, :mass]  == mass.([ChemicalSpecies(:Si), ChemicalSpecies(:C)])
    @test system[[1, 3], :mass]  == mass.([ChemicalSpecies(:Si), ChemicalSpecies(:H)])
    @test system[[false, true, true], :species] == ChemicalSpecies.([:C, :H])
    @test system[:bounding_box] == box
    @test atomkeys(system) == (:position, :velocity, :species, :mass)
    @test hasatomkey(system, :mass)
    @test !hasatomkey(system, :blubber)
    @test get(system, :blubber, :adidi) == :adidi

    @test collect(pairs(system)) == [
        :bounding_box => box, :periodicity => pbcs,
        :extradata => 45, :dic => dic
    ]
    @test collect(pairs(system[1])) == [
        :position => [0.0, 1.0, 1.5]u"Å",
        :velocity => zeros(3)u"Å/s",
        :species  => ChemicalSpecies(:Si),
        :mass     => AtomsBase.element(:Si).atomic_mass,
    ]

    # Test update constructor
    newatoms  = [system[1], system[2]]
    newsystem = AbstractSystem(system; atoms=newatoms, periodicity=[true, true, true])
    @test newsystem isa FlexibleSystem
    @test length(newsystem) == 2
    @test atomic_symbol(newsystem, :) == [:Si, :C]
    @test periodicity(newsystem) == (true, true, true)
    @test position(newsystem, :) == [[0.0, 1.0, 1.5], [0.0, 0.8, 1.7]]u"Å"
end
