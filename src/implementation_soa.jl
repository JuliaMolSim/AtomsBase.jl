# Example implementation using as few function definitions as possible
#
using StaticArrays

export FastAtom, SoASystem

struct FastAtom{D} <: AbstractAtom
    position::SVector{D, <:Unitful.Length}
    element::ChemicalElement
end
FastAtom(position, element)  = FastAtom{length(position)}(position, element)
position(atom::FastAtom) = atom.position
element(atom::FastAtom)  = atom.element

function FastAtom(position, symbol::Union{Integer,AbstractString,Symbol,AbstractVector})
    FastAtom(position, ChemicalElement(symbol))
end

struct SoASystem{N, D, ET<:AbstractElement, AT<:AbstractParticle{ET}} <: AbstractSystem{D,ET,AT}
    box::SVector{D, SVector{D, <:Unitful.Length}}
    boundary_conditions::SVector{D, <:BoundaryCondition}
    positions::SMatrix{N,D,<:Unitful.Length}
    elements::SVector{N,ET}
    # janky inner constructor that we need for some reason
    SoASystem(box, bcs, positions, els) = new{length(els), length(bcs), typeof(els[1]), FastAtom}(box,bcs,positions,els)
end
function Base.show(io::IO, ::MIME"text/plain", sys::SoASystem)
    print(io, "SoASystem with ", length(sys), " particles")
end

bounding_box(sys::SoASystem) = sys.box
boundary_conditions(sys::SoASystem) = sys.boundary_conditions

# Base.size(sys::SoASystem) = size(sys.particles)
Base.length(::SoASystem{N,D,ET,AT}) where {N,D,ET,AT} = N

# first piece of trickiness: can't do a totally abstract dispatch here because we need to know the signature of the constructor for AT
Base.getindex(sys::SoASystem{FastAtom{D},D,N}, i::Int) where {D,N} = FastAtom{D}(sys.positions[i,:],sys.elements[i])

