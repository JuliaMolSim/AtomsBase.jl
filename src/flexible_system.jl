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

# Update constructor
function FlexibleSystem(system::AbstractSystem;
                        particles=nothing, atoms=nothing,
                        box=bounding_box(system),
                        boundary_conditions=boundary_conditions(system),
                        kwargs...)
    particles = something(particles, atoms, collect(system))
    extra = system isa FlexibleSystem ? system.data : (; )
    FlexibleSystem(particles, box, boundary_conditions; extra..., kwargs...)
end
FlexibleSystem(;system::FlexibleSystem, kwargs...) = FlexibleSystem(system; kwargs...)

function Base.show(io::IO, system::FlexibleSystem)
    print(io, "FlexibleSystem")
    show_system(io, system)
end

bounding_box(sys::FlexibleSystem)        = sys.box
boundary_conditions(sys::FlexibleSystem) = sys.boundary_conditions
species_type(sys::FlexibleSystem{D, S, L}) where {D, S, L} = S

Base.size(sys::FlexibleSystem)   = size(sys.particles)
Base.length(sys::FlexibleSystem) = length(sys.particles)
Base.getindex(sys::FlexibleSystem, i::Integer) = getindex(sys.particles, i)
