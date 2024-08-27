

#
# Implementation of AtomsBase interface in an array-of-structs style
#
export FlexibleSystem


struct FlexibleSystem{D, S, TCELL} <: AbstractSystem{D}
    particles::AbstractVector{S}
    cell::TCELL
    data::Dict{Symbol, Any}  # Store arbitrary data about the atom.
end

cell(sys::FlexibleSystem) = sys.cell

# System property access
function Base.getindex(system::FlexibleSystem, x::Symbol)
    if x === :bounding_box
        bounding_box(system)
    elseif x === :periodicity
        periodicity(system)
    else
        getindex(system.data, x)
    end
end

function Base.haskey(system::FlexibleSystem, x::Symbol)
    x in (:bounding_box, :periodicity) || haskey(system.data, x)
end

Base.keys(system::FlexibleSystem) = (:bounding_box, :periodicity, keys(system.data)...)

# Atom and atom property access
Base.getindex(system::FlexibleSystem, i::Integer) = system.particles[i]
Base.getindex(system::FlexibleSystem, i::Integer, x::Symbol) = system.particles[i][x]
function Base.getindex(system::FlexibleSystem, i::AbstractVector, x::Symbol)
    [at[x] for at in system.particles[i]]
end
Base.getindex(system::FlexibleSystem, ::Colon, x::Symbol) = [at[x] for at in system.particles]


"""
    FlexibleSystem(particles, bounding_box, periodicity; kwargs...)
    FlexibleSystem(particles; bounding_box, periodicity, kwargs...)
    FlexibleSystem(particles, cell; kwargs...)

Construct a flexible system, a versatile data structure for atomistic systems,
which puts an emphasis on flexibility rather than speed.
"""
function FlexibleSystem(
    particles::AbstractVector{S},
    box::NTuple{D, <: AbstractVector{L}},
    periodicity::Union{Bool, NTuple{D, Bool}, AbstractVector{<: Bool}};
    kwargs...
) where {L<:Unitful.Length, S, D}
    if periodicity isa Bool 
        periodicity = ntuple(_ -> periodicity, D)
    else 
        periodicity = tuple(periodicity...)
    end
    if !all(length.(box) .== D)
        throw(ArgumentError("Box must have D vectors of length D"))
    end
    cϵll = PeriodicCell(; cell_vectors = box, periodicity = periodicity)
    FlexibleSystem{D, S, typeof(cϵll)}(particles, cϵll, Dict(kwargs...))
end

function FlexibleSystem(particles; bounding_box, periodicity, kwargs...)
    FlexibleSystem(particles, bounding_box, periodicity; kwargs...)
end

function FlexibleSystem(particles::AbstractVector, cell; kwargs...) 
    D = n_dimensions(cell)
    S = eltype(particles)
    TCELL = typeof(cell)
    data = Dict{Symbol, Any}(kwargs...)
    return FlexibleSystem{D, S, TCELL}(particles, cell, data) 
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

Supported `kwargs` include `particles`, `atoms`, `bounding_box` and `periodicity`
as well as user-specific custom properties.

# Examples
Change the bounding box and the atoms of the passed system
```julia-repl
julia> AbstractSystem(system; bounding_box= ..., atoms = ... )
```
"""
AbstractSystem(system::AbstractSystem; kwargs...) = FlexibleSystem(system; kwargs...)

# TODO - I don't think this is part of the interface.
#        it is also tied to eltype somewhere else. Sounds dangerous and hacky. 
# species_type(sys::FlexibleSystem{D, S, L}) where {D, S, L} = S

Base.size(sys::FlexibleSystem)   = size(sys.particles)
Base.length(sys::FlexibleSystem) = length(sys.particles)

position(sys::FlexibleSystem, i::Integer) = 
        position(sys.particles[i])

position(sys::FlexibleSystem, i::Union{AbstractVector, Colon}) = 
        [ position(x) for x in sys.particles[i] ] 

velocity(sys::FlexibleSystem, i::Integer) = 
        velocity(sys.particles[i])

velocity(sys::FlexibleSystem, i::Union{AbstractVector, Colon}) = 
        [ velocity(x) for x in sys.particles[i] ]         

mass(sys::FlexibleSystem, i::Integer) = 
        mass(sys.particles[i])

mass(sys::FlexibleSystem, i::Union{AbstractVector, Colon}) = 
        [ mass(x) for x in sys.particles[i] ]

species(sys::FlexibleSystem, i::Integer) = 
        species(sys.particles[i])

species(sys::FlexibleSystem, i::Union{AbstractVector, Colon}) = 
        [ species(x) for x in sys.particles[i] ]                         