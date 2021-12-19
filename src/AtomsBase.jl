module AtomsBase
using Unitful
using UnitfulAtomic
import PeriodicTable: elements
using StaticArrays

include("interface.jl")
include("atom.jl")
include("flexible_system.jl")
include("atomview.jl")
include("fast_system.jl")

"""Flexible chemical system implementation consisting of `AtomsBase.Atom` species."""
AtomicSystem = FlexibleSystem{D, Atom{D, L, M}, L} where {D, L, M}

end
