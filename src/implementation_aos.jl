# Example implementation using as few function definitions as possible
#
using StaticArrays

export AoSAtom, AoSSystem, AoSAtomicSystem

struct AoSAtom{D} <: AbstractAtom
    position::SVector{D, Unitful.Length}
    element::ChemicalElement
end
AoSAtom(position, element)  = AoSAtom{length(position)}(position, element)
position(atom::AoSAtom) = atom.position
element(atom::AoSAtom)  = atom.element

function AoSAtom(position, symbol::Union{Integer,AbstractString,Symbol,AbstractVector})
    AoSAtom(position, ChemicalElement(symbol))
end

# TODO Switch order of type arguments?
struct AoSSystem{D, ET<:AbstractElement, AT<:AbstractParticle{ET}} <: AbstractSystem{D,ET,AT}
    box::SVector{D, SVector{D, Unitful.Length}}
    boundary_conditions::SVector{D, BoundaryCondition}
    particles::Vector{AT}
end
bounding_box(sys::AoSSystem) = sys.box
boundary_conditions(sys::AoSSystem) = sys.boundary_conditions

Base.size(sys::AoSSystem) = size(sys.particles)
Base.length(sys::AoSSystem) = length(sys.particles)
Base.getindex(sys::AoSSystem, i::Int) = getindex(sys.particles, i)
