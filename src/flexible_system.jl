#
# Implementation of AtomsBase interface in an array-of-structs style
#
export FlexibleSystem

struct FlexibleSystem{D, S, L<:Unitful.Length} <: AbstractSystem{D}
    box::SVector{D, SVector{D, L}}
    boundary_conditions::SVector{D, BoundaryCondition}
    particles::AbstractVector{S}
end

function FlexibleSystem(
    box::AbstractVector{<:AbstractVector{L}},
    particles::AbstractVector{S},
    boundary_conditions::AbstractVector{BC}=fill(DirichletZero(), length(box)),
) where {BC<:BoundaryCondition, L<:Unitful.Length, S}
    D = length(box)
    if !all(length.(box) .== D)
        throw(ArgumentError("Box must have D vectors of length D"))
    end
    FlexibleSystem{D, S, L}(box, boundary_conditions, particles)
end

bounding_box(sys::FlexibleSystem)        = sys.box
boundary_conditions(sys::FlexibleSystem) = sys.boundary_conditions
species_type(sys::FlexibleSystem{D, S, L}) where {D, S, L} = S

Base.size(sys::FlexibleSystem)   = size(sys.particles)
Base.length(sys::FlexibleSystem) = length(sys.particles)
Base.getindex(sys::FlexibleSystem, i::Integer) = getindex(sys.particles, i)
