# Example implementation using as few function definitions as possible
#
using StaticArrays

export SoASystem

struct SoASystem{N, D, ET<:AbstractElement, AT<:AbstractParticle{ET}, T<:Unitful.Length} <: AbstractSystem{D,ET,AT}
    box::SVector{D, SVector{D, <:Unitful.Length}}
    boundary_conditions::SVector{D, <:BoundaryCondition}
    positions::Array{SVector{D,T}}
    elements::Array{ET}
    # janky inner constructor that we need for some reason
    SoASystem(box, bcs, positions, els) = new{length(els), length(bcs), eltype(els), SimpleAtom, eltype(eltype(positions))}(box, bcs, positions, els)
end
function Base.show(io::IO, ::MIME"text/plain", sys::SoASystem)
    print(io, "SoASystem with ", length(sys), " particles")
end

bounding_box(sys::SoASystem) = sys.box
boundary_conditions(sys::SoASystem) = sys.boundary_conditions

# Base.size(sys::SoASystem) = size(sys.particles)
Base.length(::SoASystem{N,D,ET,AT}) where {N,D,ET,AT} = N

# first piece of trickiness: can't do a totally abstract dispatch here because we need to know the signature of the constructor for AT
Base.getindex(sys::SoASystem{N,D,ET,SimpleAtom}, i::Int) where {N,D,ET} = SimpleAtom{D}(sys.positions[i,:],sys.elements[i])
