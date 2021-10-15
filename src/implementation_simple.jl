# Example implementation using as few function definitions as possible
#
using StaticArrays

export SimpleAtom, SimpleSystem, SimpleAtomicSystem

struct SimpleAtom{D} <: AbstractAtom
    position::SVector{D, Unitful.Length}
    element::Element
end
SimpleAtom(position, element)  = SimpleAtom{length(position)}(position, element)
get_position(atom::SimpleAtom) = atom.position
get_element(atom::SimpleAtom)  = atom.element

function SimpleAtom{D}(position, symbol::Union{Integer,AbstractString,Symbol,AbstractVector}) where D
    SimpleAtom{D}(position, Element(symbol))
end

# TODO Switch order of type arguments?
struct SimpleSystem{E<:AbstractElement, AT <: AbstractParticle{E},D} <: AbstractSystem{E, AT,D}
    box::SVector{D, SVector{D, Unitful.Length}}
    boundary_conditions::SVector{D, BoundaryCondition}
    particles::Vector{AT}
end
get_box(sys::SimpleSystem) = sys.box
get_boundary_conditions(sys::SimpleSystem) = sys.boundary_conditions

Base.size(sys::SimpleSystem) = size(sys.particles)
Base.length(sys::SimpleSystem) = length(sys.particles)
Base.getindex(sys::SimpleSystem, i::Int) = getindex(sys.particles, i)

SimpleAtomicSystem{D} = SimpleSystem{D, SimpleAtom{D}}
