# Example implementation using as few function definitions as possible
#
using StaticArrays

export SimpleAtom, SimpleSystem, SimpleAtomicSystem

struct SimpleAtom{D} <: AbstractAtom
    position::SVector{D, Unitful.Length}
    element::ChemicalElement
end
SimpleAtom(position, element)  = SimpleAtom{length(position)}(position, element)
position(atom::SimpleAtom) = atom.position
element(atom::SimpleAtom)  = atom.element

function SimpleAtom(position, symbol::Union{Integer,AbstractString,Symbol,AbstractVector})
    SimpleAtom(position, ChemicalElement(symbol))
end

# TODO Switch order of type arguments?
struct SimpleSystem{D, ET<:AbstractElement, AT<:AbstractParticle{ET}} <: AbstractSystem{D,ET,AT}
    box::SVector{D, SVector{D, Unitful.Length}}
    boundary_conditions::SVector{D, BoundaryCondition}
    particles::Vector{AT}
end
box(sys::SimpleSystem) = sys.box
boundary_conditions(sys::SimpleSystem) = sys.boundary_conditions

Base.size(sys::SimpleSystem) = size(sys.particles)
Base.length(sys::SimpleSystem) = length(sys.particles)
Base.getindex(sys::SimpleSystem, i::Int) = getindex(sys.particles, i)
