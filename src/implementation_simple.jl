# Example implementation using as few function definitions as possible
#
using StaticArrays

export SimpleAtom, SimpleSystem

struct SimpleAtom{D, T<:Unitful.Length} <: AbstractAtom
    position::SVector{D, T}
    element::ChemicalElement
end
SimpleAtom(position, element)  = SimpleAtom{length(position), eltype(position)}(position, element)
position(atom::SimpleAtom) = atom.position
element(atom::SimpleAtom)  = atom.element

function SimpleAtom(position, symbol::Union{Integer,AbstractString,Symbol,AbstractVector})
    SimpleAtom(position, ChemicalElement(symbol))
end

# TODO Switch order of type arguments?
struct SimpleSystem{D, ET<:AbstractElement, AT<:AbstractParticle{ET}, T<:Unitful.Length} <: AbstractSystem{D,ET,AT}
    box::SVector{D, SVector{D, T}}
    boundary_conditions::SVector{D, BoundaryCondition}
    particles::Vector{AT}
end

function SimpleSystem(box, boundary_conditions, particles)
    D = length(box)
    ET = typeof(element(first(particles)))
    AT = eltype(particles)
    T = eltype(first(box))

    SimpleSystem{D, ET, AT, T}(box, boundary_conditions, particles)
end

bounding_box(sys::SimpleSystem) = sys.box
boundary_conditions(sys::SimpleSystem) = sys.boundary_conditions

Base.size(sys::SimpleSystem) = size(sys.particles)
Base.length(sys::SimpleSystem) = length(sys.particles)
Base.getindex(sys::SimpleSystem, i::Int) = getindex(sys.particles, i)
