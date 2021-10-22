# Example implementation using as few function definitions as possible
#
using StaticArrays

export SimpleAtom, AoSSystem

struct SimpleAtom{D} <: AbstractAtom
    position::SVector{D, <:Unitful.Length}
    element::ChemicalElement
end
SimpleAtom(position, element)  = SimpleAtom{length(position)}(position, element)
position(atom::SimpleAtom) = atom.position
element(atom::SimpleAtom)  = atom.element

function SimpleAtom(position, symbol::Union{Integer,AbstractString,Symbol,AbstractVector})
    SimpleAtom(position, ChemicalElement(symbol))
end

# TODO Switch order of type arguments?
struct AoSSystem{D, ET<:AbstractElement, AT<:AbstractParticle{ET}} <: AbstractSystem{D,ET,AT}
    box::SVector{D, <:SVector{D, <:Unitful.Length}}
    boundary_conditions::SVector{D, <:BoundaryCondition}
    particles::Vector{AT}
end
bounding_box(sys::AoSSystem) = sys.box
boundary_conditions(sys::AoSSystem) = sys.boundary_conditions
function Base.show(io::IO, ::MIME"text/plain", sys::AoSSystem)
    print(io, "AoSSystem with ", length(sys), " particles")
end

Base.size(sys::AoSSystem) = size(sys.particles)
Base.length(sys::AoSSystem) = length(sys.particles)
Base.getindex(sys::AoSSystem, i::Int) = getindex(sys.particles, i)
