# Example implementation using as few function definitions as possible
#
include("interface.jl")
using StaticArrays

struct SimpleAtom{N} <: AbstractAtom
    position::SVector{N, Length, N}
    symbol::Symbol
end
get_position(atom::SimpleAtom)      = atom.position
get_atomic_symbol(atom::SimpleAtom) = atom.symbol

struct SimpleSystem{N, AT <: AbstractParticle} <: AbstractSystem{AT}
    cell::SVector{N, SVector{N, Length, N}, N}
    boundary_conditions::SVector{N, BoundaryCondition, N}
    particles::Vector{AT}
end
get_cell(sys::SimpleSystem) = sys.cell
size(sys::SimpleSystem)     = size(sys.particles)
get_boundary_conditions(sys::SimpleSystem) = sys.boundary_conditions

SimpleAtomicSystem{N} = SimpleSystem{N, SimpleAtom{N}}
