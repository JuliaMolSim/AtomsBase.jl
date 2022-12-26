using AtomsBase
using Unitful
using Test

@testset "Printing atomic systems" begin
    at = Atom(:Si, zeros(3) * u"m", extradata=42)
    @test repr(at) == "Atom(Si, [       0,        0,        0]u\"m\")"
    show(stdout, MIME("text/plain"), at)

    atoms = [:Si => [0.0, -0.125, 0.0],
             :C  => [0.125, 0.0, 0.0]]
    box = [[10, 0.0, 0.0], [0.0, 5, 0.0], [0.0, 0.0, 7]]u"Å"

    flexible_system = periodic_system(atoms, box; fractional=true, data=-12)
    @test repr(flexible_system) == """
    FlexibleSystem(CSi, periodic = TTT, bounding_box = [[10.0, 0.0, 0.0], [0.0, 5.0, 0.0], [0.0, 0.0, 7.0]]u"Å")"""
    show(stdout, MIME("text/plain"), flexible_system)

    fast_system = FastSystem(flexible_system)
    @test repr(fast_system) == """
    FastSystem(CSi, periodic = TTT, bounding_box = [[10.0, 0.0, 0.0], [0.0, 5.0, 0.0], [0.0, 0.0, 7.0]]u"Å")"""
    show(stdout, MIME("text/plain"), fast_system)
    show(stdout, MIME("text/plain"), fast_system[1])
end
