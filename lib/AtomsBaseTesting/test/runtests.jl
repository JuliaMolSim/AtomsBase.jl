using AtomsBaseTesting
using Test
using LinearAlgebra
using AtomsBase
using Unitful
using UnitfulAtomic

include("testmacros.jl")

@testset "AtomsBaseTesting.jl" begin
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

    @testset "Identical systems should pass" begin
        case = make_test_system()
        test_approx_eq(case.system, case.system)
    end

    @testset "Cell distortion" begin
        (; system, atoms, box, bcs, sysprop) = make_test_system()

        box_dist = [v .+ 1e-5u"Å" * ones(3) for v in box]
        system_dist = atomic_system(atoms, box_dist, bcs; sysprop...)

        @testfail test_approx_eq(system, system_dist; rtol=1e-12)
        @testpass test_approx_eq(system, system_dist; rtol=1e-3)
    end

    @testset "ignore_sysprop / common_only" begin
        (; system, atoms, box, bcs, sysprop) = make_test_system()

        sysprop_dict = Dict(pairs(sysprop))
        pop!(sysprop_dict, :multiplicity)
        system_edit = atomic_system(atoms, box, bcs; sysprop_dict...)

        @testfail test_approx_eq(system, system_edit)
        @testpass test_approx_eq(system, system_edit; ignore_sysprop=[:multiplicity])
        @testpass test_approx_eq(system, system_edit; common_only=true)
    end

    # TODO More tests would be useful
end
