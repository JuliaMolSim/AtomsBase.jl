using AtomsBase
using Unitful
using UnitfulAtomic
using Test

@testset "Making systems" begin
    @testset "isolated_system" begin
        dic = Dict{String, Any}("extradata_dic"=>"47")
        system = isolated_system([:Si => [0.0, 1.0, 1.5]u"Å",
                                  :C  => [0.0, 0.8, 1.7]u"Å",
                                  Atom(:H, zeros(3) * u"Å")], extradata=46; dic)
        @test length(system) == 3
        @test species(system, :) == ChemicalSpecies.([:Si, :C, :H])
        @test periodicity(system) == (false, false, false)
        @test cell(system) isa IsolatedCell
        @test position(system, :) == [[0.0, 1.0, 1.5], [0.0, 0.8, 1.7], [0.0, 0.0, 0.0]]u"Å"
        @test velocity(system, :) == [[0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0]]u"bohr/s"
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
        @test species(system, :) == ChemicalSpecies.([:Si, :C, :H])
        @test periodicity(system) == (true, true, true)
        @test cell(system) isa PeriodicCell
        @test position(system, :) == [[0.0, -0.625, 0.0], [1.25, 0.0, 0.0], [0.0, 0.0, 0.0]]u"Å"
        @test cell_vectors(system)[1] == box[1]
        @test cell_vectors(system)[2] == box[2]
        @test cell_vectors(system)[3] == box[3]
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
end
