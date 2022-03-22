using AtomsBase
using Unitful
using Test

@testset "Printing atomic systems" begin
    at = Atom(:Si, zeros(3) * u"m", extradata=42)
    println(at)

    atoms = [:Si => [0.0, -0.125, 0.0],
             :C  => [0.125, 0.0, 0.0]]
    box = [[10, 0.0, 0.0], [0.0, 5, 0.0], [0.0, 0.0, 7]]u"Å"
    system = periodic_system(atoms, box; fractional=true)
    println(system)
end
