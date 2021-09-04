# Example implementation using as few function definitions as possible
#
using StaticArrays

export SimpleAtom, SimpleSystem, SimpleAtomicSystem

struct SimpleAtom{N} <: AbstractAtom
    position::SVector{N, Unitful.Length}
    symbol::Symbol
end
get_position(atom::SimpleAtom)      = atom.position
get_atomic_symbol(atom::SimpleAtom) = atom.symbol

# TODO Switch order of type arguments?
struct SimpleSystem{N, AT <: AbstractParticle} <: AbstractSystem{AT}
    cell::SVector{N, SVector{N, Unitful.Length}}
    boundary_conditions::SVector{N, BoundaryCondition}
    particles::Vector{AT}
end
get_cell(sys::SimpleSystem)  = sys.cell
get_boundary_conditions(sys::SimpleSystem) = sys.boundary_conditions

Base.size(sys::SimpleSystem) = size(sys.particles)
Base.getindex(sys::SimpleSystem, i::Int) = getindex(sys.particles, i)

SimpleAtomicSystem{N} = SimpleSystem{N, SimpleAtom{N}}
