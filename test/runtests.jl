using Test
using Pkg

const GROUP = get(ENV, "GROUP", "Core")
const GROUP_COVERAGE = !isempty(get(ENV, "GROUP_COVERAGE", ""))

if GROUP == "Core"
    @testset "AtomsBase.jl" begin
        include("interface.jl")
        include("fast_system.jl")
        include("atom.jl")
        include("properties.jl")
        include("printing.jl")
    end
else
    subpkg_path = joinpath(dirname(@__DIR__), "lib", GROUP)
    Pkg.develop(PackageSpec(path=subpkg_path))
    Pkg.test(PackageSpec(name=GROUP, path=subpkg_path), coverage=GROUP_COVERAGE)
end
