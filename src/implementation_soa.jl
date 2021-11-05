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
    SoASystem(box, bcs, positions, elements) = new{length(elements), length(bcs), eltype(elements), SimpleAtom, eltype(eltype(positions))}(box, bcs, positions, elements)
end

# convenience constructor where we don't have to preconstruct all the static stuff...
function SoASystem(box::Vector{Vector{L}}, bcs::Vector{BC}, positions::Matrix{M}, elements::Vector{ET}) where {BC<:BoundaryCondition, L<:Unitful.Length, M<:Unitful.Length, ET<:AbstractElement}
    N = length(elements)
    D = length(box)
    @assert all(length.(box) .== D)
    @assert size(positions, 1) == N
    @assert size(positions, 2) == D
    sbox = SVector{D, SVector{D, L}}(box)
    sbcs = SVector{D, BoundaryCondition}(bcs)
    spos = Vector{SVector{D,eltype(positions)}}([positions[i,:] for i in 1:N])
    SoASystem(sbox, sbcs, spos, elements)
end

function Base.show(io::IO, ::MIME"text/plain", sys::SoASystem)
    print(io, "SoASystem with ", length(sys), " particles")
end

bounding_box(sys::SoASystem) = sys.box
boundary_conditions(sys::SoASystem) = sys.boundary_conditions

# Base.size(sys::SoASystem) = size(sys.particles)
Base.length(::SoASystem{D,ET,AT}) where {D,ET,AT} = N

# first piece of trickiness: can't do a totally abstract dispatch here because we need to know the signature of the constructor for AT
Base.getindex(sys::SoASystem{D,ET,SimpleAtom}, i::Int) where {D,ET} = SimpleAtom{D}(sys.positions[i],sys.elements[i])
