#=
Implementation of AtomsBase interface in an struct-of-arrays style.
=#

using StaticArrays

export FastSystem

struct FastSystem{D,S,L<:Unitful.Length} <:
       AbstractSystem{D,S}
    box::SVector{D,SVector{D,L}}
    boundary_conditions::SVector{D,BoundaryCondition}
    positions::Vector{SVector{D,L}}
    elements::Vector{S}
    # janky inner constructor that we need for some reason
    FastSystem(box, boundary_conditions, positions, elements) =
        new{length(boundary_conditions),eltype(elements),eltype(eltype(positions))}(
            box,
            boundary_conditions,
            positions,
            elements,
        )
end

# convenience constructor where we don't have to preconstruct all the static stuff...
function FastSystem(
    box::Vector{<:AbstractVector{L}},
    boundary_conditions::AbstractVector{BC},
    positions::AbstractMatrix{M},
    elements::AbstractVector{S},
) where {L<:Unitful.Length,BC<:BoundaryCondition,M<:Unitful.Length,S}
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
    FastSystem(
        SVector{D,SVector{D,L}}(box),
        SVector{D,BoundaryCondition}(boundary_conditions),
        Vector{SVector{D,eltype(positions)}}([positions[i, :] for i = 1:N]),
        elements,
    )
end

function Base.show(io::IO, sys::FastSystem)
    print(io, "FastSystem with ", length(sys), " particles")
end

bounding_box(sys::FastSystem) = sys.box
boundary_conditions(sys::FastSystem) = sys.boundary_conditions

# Base.size(sys::FastSystem) = size(sys.particles)
Base.length(sys::FastSystem{D,S}) where {D,S} = length(sys.elements)

Base.getindex(sys::FastSystem{D,S,L}, i::Int) where {D,S,L} =
    StaticAtom{D,L}(sys.positions[i], sys.elements[i])

# these dispatches aren't strictly necessary, but they make these functions ~2x faster
position(s::FastSystem) = s.positions
species(s::FastSystem) = s.elements