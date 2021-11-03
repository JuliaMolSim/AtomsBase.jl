# Example implementation using as few function definitions as possible
#
using StaticArrays

export AoSSystem

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
