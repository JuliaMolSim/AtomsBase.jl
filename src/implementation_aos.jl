# Example implementation using as few function definitions as possible
#
using StaticArrays

export FlexibleSystem

# TODO Switch order of type arguments?
struct FlexibleSystem{D,ET<:AbstractElement,AT<:AbstractParticle{ET}} <: AbstractSystem{D,ET,AT}
    box::SVector{D,<:SVector{D,<:Unitful.Length}}
    boundary_conditions::SVector{D,<:BoundaryCondition}
    particles::Vector{AT}
end
# convenience constructor where we don't have to preconstruct all the static stuff...
function FlexibleSystem(
    box::Vector{Vector{L}},
    boundary_conditions::Vector{BC},
    particles::Vector{AT},
) where {BC<:BoundaryCondition,L<:Unitful.Length,AT<:AbstractParticle}
    D = length(box)
    if !all(length.(box) .== D)
        throw(ArgumentError("box must have D vectors of length D"))
    end
    FlexibleSystem(SVector{D,SVector{D,L}}(box), SVector{D,BoundaryCondition}(boundary_conditions), particles)
end

bounding_box(sys::FlexibleSystem) = sys.box
boundary_conditions(sys::FlexibleSystem) = sys.boundary_conditions

function Base.show(io::IO, ::MIME"text/plain", sys::FlexibleSystem)
    print(io, "FlexibleSystem with ", length(sys), " particles")
end

Base.size(sys::FlexibleSystem) = size(sys.particles)
Base.length(sys::FlexibleSystem) = length(sys.particles)
Base.getindex(sys::FlexibleSystem, i::Int) = getindex(sys.particles, i)
