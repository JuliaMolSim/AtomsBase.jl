# Example implementation using as few function definitions as possible
#
using StaticArrays

export SoAAtom, SoASystem, SoAAtomicSystem

struct SoAAtom{D} <: AbstractAtom
    position::SVector{D, Unitful.Length}
    element::ChemicalElement
end
SoAAtom(position, element)  = SoAAtom{length(position)}(position, element)
position(atom::SoAAtom) = atom.position
element(atom::SoAAtom)  = atom.element

function SoAAtom(position, symbol::Union{Integer,AbstractString,Symbol,AbstractVector})
    SoAAtom(position, ChemicalElement(symbol))
end

# static number of particles (not necessary, but simple)
struct SoASystem{N<:Integer, D, ET<:AbstractElement, AT<:AbstractParticle{ET}} <: AbstractSystem{D,ET,AT}
    box::SVector{D, SVector{D, Unitful.Length}}
    boundary_conditions::SVector{D, BoundaryCondition}
    positions::SMatrix{N,D,Unitful.Length}
    elements::SVector{N,ET}
end
bounding_box(sys::SoASystem) = sys.box
boundary_conditions(sys::SoASystem) = sys.boundary_conditions

# Base.size(sys::SoASystem) = size(sys.particles)
Base.length(::SoASystem{N}) where {N} = N

# first piece of trickiness: can't do a totally abstract dispatch here because we need to know the signature of the constructor for AT
Base.getindex(sys::SoASystem{SoAAtom{D},D,N}, i::Int) where {D,N} = SoAAtom{D}(sys.positions[i,:],sys.elements[i])

