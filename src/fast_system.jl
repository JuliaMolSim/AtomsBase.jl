#
# Implementation of AtomsBase interface in a struct-of-arrays style.
#
export FastSystem

struct FastSystem{D, L <: Unitful.Length, M <: Unitful.Mass} <: AbstractSystem{D}
    bounding_box::SVector{D, SVector{D, L}}
    boundary_conditions::SVector{D, BoundaryCondition}
    position::Vector{SVector{D, L}}
    atomic_symbol::Vector{Symbol}
    atomic_number::Vector{Int}
    atomic_mass::Vector{M}
end

# Constructor to fetch the types
function FastSystem(box, boundary_conditions, positions, atomic_symbols, atomic_numbers, atomic_masses)
    FastSystem{length(box),eltype(eltype(positions)),eltype(atomic_masses)}(
        box, boundary_conditions, positions, atomic_symbols, atomic_numbers, atomic_masses
    )
end

# Constructor to take data from another system
function FastSystem(system::AbstractSystem)
    FastSystem(bounding_box(system), boundary_conditions(system), position(system),
               atomic_symbol(system), atomic_number(system), atomic_mass(system))
end

# Convenience constructor where we don't have to preconstruct all the static stuff...
function FastSystem(particles, box, boundary_conditions)
    D = length(box)
    if !all(length.(box) .== D)
        throw(ArgumentError("Box must have D vectors of length D=$D."))
    end
    if length(boundary_conditions) != D
        throw(ArgumentError("Boundary conditions should be of length D=$D."))
    end
    if !all(n_dimensions.(particles) .== D)
        throw(ArgumentError("Particles must have positions of length D=$D."))
    end
    FastSystem(box, boundary_conditions, position.(particles), atomic_symbol.(particles),
               atomic_number.(particles), atomic_mass.(particles))
end

bounding_box(sys::FastSystem)        = sys.bounding_box
boundary_conditions(sys::FastSystem) = sys.boundary_conditions
Base.length(sys::FastSystem)         = length(sys.position)
Base.size(sys::FastSystem)           = size(sys.position)

species_type(::FS) where {FS <: FastSystem} = AtomView{FS}
Base.getindex(sys::FastSystem, i::Integer)  = AtomView(sys, i)

position(s::FastSystem)       = s.position
atomic_symbol(s::FastSystem)  = s.atomic_symbol
atomic_number(s::FastSystem)  = s.atomic_number
atomic_mass(s::FastSystem)    = s.atomic_mass
velocity(::FastSystem)        = missing

# System property access
function Base.getindex(system::FastSystem, x::Symbol)
    if x === :bounding_box
        bounding_box(system)
    elseif x === :boundary_conditions
        boundary_conditions(system)
    else
        throw(KeyError(x))
    end
end
Base.haskey(::FastSystem, x::Symbol) = x in (:bounding_box, :boundary_conditions)
Base.keys(::FastSystem) = (:bounding_box, :boundary_conditions)

# Atom and atom property access
atomkeys(::FastSystem) = (:position, :atomic_symbol, :atomic_number, :atomic_mass)
hasatomkey(system::FastSystem, x::Symbol) = x in atomkeys(system)
Base.getindex(system::FastSystem, i::Integer, x::Symbol) = getfield(system, x)[i]
Base.getindex(system::FastSystem, ::Colon, x::Symbol) = getfield(system, x)
