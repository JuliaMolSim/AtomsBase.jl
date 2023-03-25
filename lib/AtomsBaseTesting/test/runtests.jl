using AtomsBaseTesting
using Test
using LinearAlgebra
using AtomsBase

@testset "AtomsBaseTesting.jl" begin
    @testset "Run generation and testing code" begin
        case = make_test_system()
        test_approx_eq(case.system, case.system)
    end

    @testset "make_test_system" begin
        let case = make_test_system(; cellmatrix=:full)
            box = reduce(hcat, bounding_box(case.system))
            @test UpperTriangular(box) != box
            @test LowerTriangular(box) != box
        end
        let case = make_test_system(; cellmatrix=:upper_triangular)
            box = reduce(hcat, bounding_box(case.system))
            @test UpperTriangular(box) == box
            @test LowerTriangular(box) != box
        end
        let case = make_test_system(; cellmatrix=:lower_triangular)
            box = reduce(hcat, bounding_box(case.system))
            @test UpperTriangular(box) != box
            @test LowerTriangular(box) == box
        end

        @test  hasatomkey(make_test_system().system,                            :vdw_radius)
        @test !hasatomkey(make_test_system(; drop_atprop=[:vdw_radius]).system, :vdw_radius)

        @test  haskey(make_test_system().system,                               :multiplicity)
        @test !haskey(make_test_system(; drop_sysprop=[:multiplicity]).system, :multiplicity)
    end
end
