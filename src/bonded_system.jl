#
# Implementation of AtomsBase interface in a struct-of-arrays style with bonds.
#
export BondedSystem

struct BondedSystem{D, L <: Unitful.Length, M <: Unitful.Mass} <: AbstractSystem{D}
    bounding_box::SVector{D, SVector{D, L}}
    boundary_conditions::SVector{D, BoundaryCondition}
    position::Vector{SVector{D, L}}
    bonds::Vector{Tuple{Integer, Integer, BondOrder}}
    atomic_symbol::Vector{Symbol}
    atomic_number::Vector{Int}
    atomic_mass::Vector{M}
end

# Constructor to fetch the types
function BondedSystem(box, boundary_conditions, positions, bonds, atomic_symbols, atomic_numbers, atomic_masses)
    BondedSystem{length(box),eltype(eltype(positions)),eltype(atomic_masses)}(
        box, boundary_conditions, positions, bonds, atomic_symbols, atomic_numbers, atomic_masses
    )
end

# Constructor to take data from another system
function BondedSystem(system::AbstractSystem)
    BondedSystem(bounding_box(system), boundary_conditions(system), position(system), bonds(system),
               atomic_symbol(system), atomic_number(system), atomic_mass(system))
end

# Convenience constructor where we don't have to preconstruct all the static stuff...
function BondedSystem(particles, box, boundary_conditions, bonds)
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
    BondedSystem(box, boundary_conditions, position.(particles), bonds, atomic_symbol.(particles),
               atomic_number.(particles), atomic_mass.(particles))
end

bounding_box(sys::BondedSystem)        = sys.bounding_box
boundary_conditions(sys::BondedSystem) = sys.boundary_conditions
bonds(sys::BondedSystem) = sys.bonds

Base.length(sys::BondedSystem)         = length(sys.position)
Base.size(sys::BondedSystem)           = size(sys.position)

species_type(::FS) where {FS <: BondedSystem} = AtomView{FS}
Base.getindex(sys::BondedSystem, i::Integer)  = AtomView(sys, i)

position(s::BondedSystem)       = s.position
atomic_symbol(s::BondedSystem)  = s.atomic_symbol
atomic_number(s::BondedSystem)  = s.atomic_number
atomic_mass(s::BondedSystem)    = s.atomic_mass
velocity(::BondedSystem)        = missing

# System property access
function Base.getindex(system::BondedSystem, x::Symbol)
    if x === :bounding_box
        bounding_box(system)
    elseif x === :boundary_conditions
        boundary_conditions(system)
    elseif x === :bonds
        bonds(system)
    else
        throw(KeyError(x))
    end
end
Base.haskey(::BondedSystem, x::Symbol) = x in (:bounding_box, :boundary_conditions, :bonds)
Base.keys(::BondedSystem) = (:bounding_box, :boundary_conditions, :bonds)

# Atom and atom property access
atomkeys(::BondedSystem) = (:position, :atomic_symbol, :atomic_number, :atomic_mass)
hasatomkey(system::BondedSystem, x::Symbol) = x in atomkeys(system)
function Base.getindex(system::BondedSystem, i::Union{Integer,AbstractVector}, x::Symbol)
    getfield(system, x)[i]
end
Base.getindex(system::BondedSystem, ::Colon, x::Symbol) = getfield(system, x)
