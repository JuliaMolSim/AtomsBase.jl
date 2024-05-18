#
# Implementation of AtomsBase interface in an array-of-structs style
#
export FlexibleSystem


mutable struct FlexibleSystem{D, TPART, TCELL} <: SystemWithCell{D, TCELL}
    particles::AbstractVector{TPART}
    cell::TCELL 
    data::Dict{Symbol, Any}  # Store arbitrary data about the system
end

# System property access

function Base.getindex(system::FlexibleSystem, x::Symbol)
    if x === :bounding_box
        bounding_box(system)
    elseif x === :boundary_conditions
        boundary_conditions(system)
    else
        getindex(system.data, x)
    end
end

function Base.haskey(system::FlexibleSystem, x::Symbol)
    x in (:bounding_box, :boundary_conditions) || haskey(system.data, x)
end

Base.keys(system::FlexibleSystem) = (:bounding_box, :boundary_conditions, keys(system.data)...)

# Atom and atom property access

Base.size(sys::FlexibleSystem)   = size(sys.particles)

Base.length(sys::FlexibleSystem) = length(sys.particles)

Base.getindex(system::FlexibleSystem, i::Union{Integer, AbstractVector}) = 
        system.particles[i]

Base.getindex(system::FlexibleSystem, i::Integer, x::Symbol) = 
        system.particles[i][x]

Base.getindex(system::FlexibleSystem, i::AbstractVector, x::Symbol) = 
        Base.getindex.(Ref(system), i, x)

Base.getindex(system::FlexibleSystem, ::Colon, x::Symbol) = 
        [at[x] for at in system.particles]


# ------------ Constructors         

"""
    FlexibleSystem(particles, bounding_box, boundary_conditions; kwargs...)
    FlexibleSystem(particles; bounding_box, boundary_conditions, kwargs...)

Construct a flexible system, a versatile data structure for atomistic systems,
which puts an emphasis on flexibility rather than speed.
"""
function FlexibleSystem(
        particles::AbstractVector,
        box::Union{Tuple, AbstractVector},
        boundary_conditions::Union{Tuple, AbstractVector};
        kwargs...
        ) 
    D = length(box) 
    if !all(length.(box) .== D)
        throw(ArgumentError("Box must have D vectors of length D"))
    end
    cell = PCell(box, boundary_conditions)
    FlexibleSystem(particles, box, boundary_conditions, Dict(kwargs...))
end

function FlexibleSystem(particles; bounding_box, boundary_conditions, kwargs...)
    FlexibleSystem(particles, bounding_box, boundary_conditions; kwargs...)
end

"""
    FlexibleSystem(system; kwargs...)

Update constructor. See [`AbstractSystem`](@ref) for details.
"""
function FlexibleSystem(system::AbstractSystem; particles=nothing, atoms=nothing, kwargs...)
    particles = something(particles, atoms, collect(system))
    FlexibleSystem(particles; pairs(system)..., kwargs...)
end



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

species_type(sys::FlexibleSystem{D, S, L}) where {D, S, L} = S

