module AtomsBase
using Unitful
using UnitfulAtomic
import PeriodicTable: elements
using StaticArrays

include("interface.jl")
include("properties.jl")
include("flexible_system.jl")
include("atom.jl")
include("atomview.jl")
include("fast_system.jl")

end
