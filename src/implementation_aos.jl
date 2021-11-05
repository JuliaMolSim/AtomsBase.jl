# Example implementation using as few function definitions as possible
#
using StaticArrays

export AoSSystem

# TODO Switch order of type arguments?
struct AoSSystem{D,ET<:AbstractElement,AT<:AbstractParticle{ET}} <: AbstractSystem{D,ET,AT}
    box::SVector{D,<:SVector{D,<:Unitful.Length}}
    boundary_conditions::SVector{D,<:BoundaryCondition}
    particles::Vector{AT}
end
# convenience constructor where we don't have to preconstruct all the static stuff...
function AoSSystem(
    box::Vector{Vector{L}},
    bcs::Vector{BC},
    particles::Vector{AT},
) where {BC<:BoundaryCondition,L<:Unitful.Length,AT<:AbstractParticle}
    D = length(box)
    if !all(length.(box) .== D)
        throw(ArgumentError("box must have D vectors of length D"))
    end
    sbox = SVector{D,SVector{D,L}}(box)
    sbcs = SVector{D,BoundaryCondition}(bcs)
    AoSSystem(sbox, sbcs, particles)
end

bounding_box(sys::AoSSystem) = sys.box
boundary_conditions(sys::AoSSystem) = sys.boundary_conditions

function Base.show(io::IO, ::MIME"text/plain", sys::AoSSystem)
    print(io, "AoSSystem with ", length(sys), " particles")
end

Base.size(sys::AoSSystem) = size(sys.particles)
Base.length(sys::AoSSystem) = length(sys.particles)
Base.getindex(sys::AoSSystem, i::Int) = getindex(sys.particles, i)
