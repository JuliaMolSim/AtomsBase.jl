# Example implementation using as few function definitions as possible
#
using StaticArrays

export SimpleAtom, SimpleSystem, SimpleAtomicSystem

struct SimpleAtom{N} <: AbstractAtom
    position::SVector{N, Unitful.Length}
    element::Element
end
SimpleAtom(position, element)  = SimpleAtom{length(position)}(position, element)
position(atom::SimpleAtom) = atom.position
element(atom::SimpleAtom)  = atom.element

function SimpleAtom{N}(position, symbol::Union{Integer,AbstractString,Symbol,AbstractVector}) where N
    SimpleAtom{N}(position, Element(symbol))
end

# TODO Switch order of type arguments?
struct SimpleSystem{N, AT <: AbstractParticle} <: AbstractSystem{AT}
    box::SVector{N, SVector{N, Unitful.Length}}
    boundary_conditions::SVector{N, BoundaryCondition}
    particles::Vector{AT}
end
box(sys::SimpleSystem) = sys.box
boundary_conditions(sys::SimpleSystem) = sys.boundary_conditions

Base.size(sys::SimpleSystem) = size(sys.particles)
Base.getindex(sys::SimpleSystem, i::Int) = getindex(sys.particles, i)

SimpleAtomicSystem{N} = SimpleSystem{N, SimpleAtom{N}}
