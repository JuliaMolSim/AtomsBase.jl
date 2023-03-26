module AtomsBase
using Unitful
using UnitfulAtomic
using StaticArrays

include("interface.jl")
include("properties.jl")
include("show.jl")
include("flexible_system.jl")
include("atomview.jl")
include("atom.jl")
include("fast_system.jl")

end
