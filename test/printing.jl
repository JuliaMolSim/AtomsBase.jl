using AtomsBase
using Unitful
using Test

@testset "Printing atomic systems" begin
    at = Atom(:Si, zeros(3) * u"m", extradata=42)
    @test repr(at) == "Atom(Si, [       0,        0,        0]u\"m\")"
    show(stdout, MIME("text/plain"), at)

    atoms = [:Si => [0.0, -0.125, 0.0],
             :C  => [0.125, 0.0, 0.0]]
    box = [[10, 0.0, 0.0], [0.0, 5, 0.0], [0.0, 0.0, 7]]u"bohr"

    flexible_system = periodic_system(atoms, box; fractional=true, data=-12)
    @test repr(flexible_system) == """
    FlexibleSystem(CSi, PCell(TTT, [10.0, 0.0, 0.0]a₀, [0.0, 5.0, 0.0]a₀, [0.0, 0.0, 7.0]a₀)"""
    show(stdout, MIME("text/plain"), flexible_system)

    fast_system = FastSystem(flexible_system)
    @test repr(fast_system) == """
    FastSystem(CSi, PCell(TTT, [10.0, 0.0, 0.0]a₀, [0.0, 5.0, 0.0]a₀, [0.0, 0.0, 7.0]a₀)"""
    show(stdout, MIME("text/plain"), fast_system)
    show(stdout, MIME("text/plain"), fast_system[1])
end

@testset "Test ASCII representation of structures" begin
    @testset "3D standard system" begin
        atoms = [:Si => [0.0, -0.125, 0.0],
                 :C  => [0.125, 0.0, 0.0]]
        box = [[10, 0.0, 0.0], [0.0, 5, 0.0], [0.0, 0.0, 7]]u"Å"
        system = periodic_system(atoms, box; fractional=true)
        println(visualize_ascii(system))
    end

    @testset "2D standard system" begin
        atoms = [:Si => [0.0, -0.125],
                 :C  => [0.125, 0.0]]
        box = [[10, 0.0], [0.0, 5]]u"Å"
        system = periodic_system(atoms, box; fractional=true)
        println(visualize_ascii(system))
    end

    @testset "3D with negative unit cell" begin
        atoms = [:Si => [0.75, 0.75, 0.75],
                 :Si => [0.0,  0.0,  0.0]]
        box = [[-2.73, -2.73, 0.0], [-2.73, 0.0, -2.73], [0.0, -2.73, -2.73]]u"Å"
        system = periodic_system(atoms, box; fractional=true)
        println(visualize_ascii(system))
    end
end
