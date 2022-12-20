#
# Implementation of AtomsBase interface in an array-of-structs style
#
export FlexibleSystem


struct FlexibleSystem{D, S, L<:Unitful.Length} <: AbstractSystem{D}
    particles::AbstractVector{S}
    box::SVector{D, SVector{D, L}}
    boundary_conditions::SVector{D, BoundaryCondition}
    data::Dict{Symbol, Any}  # Store arbitrary data about the atom.
end

Base.hasproperty(system::FlexibleSystem, x::Symbol) = hasfield(FlexibleSystem, x) || haskey(system.data, x)
Base.getproperty(system::FlexibleSystem, x::Symbol) = hasfield(FlexibleSystem, x) ? getfield(system, x) : getindex(system.data, x)

"""
    FlexibleSystem(particles, box, boundary_conditions; kwargs...)

Construct a flexible system, a versatile data structure for atomistic systems,
which puts an emphasis on flexibility rather than speed.
"""
function FlexibleSystem(
    particles::AbstractVector{S},
    box::AbstractVector{<:AbstractVector{L}},
    boundary_conditions::AbstractVector{BC};
    kwargs...
) where {BC<:BoundaryCondition, L<:Unitful.Length, S}
    D = length(box)
    if !all(length.(box) .== D)
        throw(ArgumentError("Box must have D vectors of length D"))
    end
    FlexibleSystem{D, S, L}(convert.(Atom, particles), box, boundary_conditions, Dict(kwargs...))
end

"""
    FlexibleSystem(system; kwargs...)

Update constructor. See [`AbstractSystem`](@ref) for details.
"""
function FlexibleSystem(system::AbstractSystem;
                        particles=nothing, atoms=nothing,
                        bounding_box=bounding_box(system),
                        boundary_conditions=boundary_conditions(system),
                        kwargs...)
    particles = something(particles, atoms, collect(system))
    extra = system isa FlexibleSystem ? system.data : (; )
    FlexibleSystem(particles, bounding_box, boundary_conditions; extra..., kwargs...)
end
Base.convert(::Type{FlexibleSystem}, system::AbstractSystem) = FlexibleSystem(system)

"""
    AbstractSystem(system::AbstractSystem; kwargs...)

Update constructor. Construct a new system where one or more properties are changed,
which are given as `kwargs`. A subtype of `AbstractSystem` is returned, by default
a `FlexibleSystem`, but depending on the type of the passed system this might differ.

Supported `kwargs` include `particles`, `atoms`, `bounding_box` and `boundary_conditions`
as well as user-specific custom properties.

# Examples
Change the bounding box and the atoms of the passed system
```julia-repl
julia> AbstractSystem(system; bounding_box= ..., atoms = ... )
```
"""
AbstractSystem(system::AbstractSystem; kwargs...) = FlexibleSystem(system; kwargs...)

bounding_box(sys::FlexibleSystem)        = sys.box
boundary_conditions(sys::FlexibleSystem) = sys.boundary_conditions
species_type(sys::FlexibleSystem{D, S, L}) where {D, S, L} = S

Base.size(sys::FlexibleSystem)   = size(sys.particles)
Base.length(sys::FlexibleSystem) = length(sys.particles)
Base.getindex(sys::FlexibleSystem, i::Integer) = getindex(sys.particles, i)
