# Example implementation using as few function definitions as possible
#
using StaticArrays

export SoASystem

struct SoASystem{D, ET<:AbstractElement, AT<:AbstractParticle{ET}, L<:Unitful.Length} <: AbstractSystem{D,ET,AT}
    box::SVector{D, SVector{D, L}}
    boundary_conditions::SVector{D, BoundaryCondition}
    positions::Vector{SVector{D,L}}
    elements::Vector{ET}
    # janky inner constructor that we need for some reason
    SoASystem(box, bcs, positions, elements) = new{length(bcs), eltype(elements), SimpleAtom, eltype(eltype(positions))}(box, bcs, positions, elements)
end

# convenience constructor where we don't have to preconstruct all the static stuff...
function SoASystem(box::AbstractVector{Vector{L}}, bcs::AbstractVector{BC}, positions::AbstractMatrix{M}, elements::AbstractVector{ET}) where {L<:Unitful.Length, BC<:BoundaryCondition, M<:Unitful.Length, ET<:AbstractElement}
    N = length(elements)
    D = length(box)
    if !all(length.(box) .== D)
        throw(ArgumentError("box must have D vectors of length D"))
    end
    if !(size(positions, 1) == N)
        throw(ArgumentError("box must have D vectors of length D"))
    end
    if !(size(positions, 2) == D)
        throw(ArgumentError("box must have D vectors of length D"))
    end
    SoASystem(SVector{D, SVector{D, L}}(box), SVector{D, BoundaryCondition}(bcs), Vector{SVector{D,eltype(positions)}}([positions[i,:] for i in 1:N]), elements)
end

function Base.show(io::IO, ::MIME"text/plain", sys::SoASystem)
    print(io, "SoASystem with ", length(sys), " particles")
end

bounding_box(sys::SoASystem) = sys.box
boundary_conditions(sys::SoASystem) = sys.boundary_conditions

# Base.size(sys::SoASystem) = size(sys.particles)
Base.length(sys::SoASystem{D,ET,AT}) where {D,ET,AT} = length(sys.elements)

# first piece of trickiness: can't do a totally abstract dispatch here because we need to know the signature of the constructor for AT
Base.getindex(sys::SoASystem{D,ET,SimpleAtom}, i::Int) where {D,ET} = SimpleAtom{D}(sys.positions[i],sys.elements[i])
