#
# Implementation of AtomsBase interface in a struct-of-arrays style.
#
export FastSystem

struct FastSystem{D, L <: Unitful.Length, M <: Unitful.Mass} <: AbstractSystem{D}
    box::SVector{D, SVector{D, L}}
    boundary_conditions::SVector{D, BoundaryCondition}
    positions::Vector{SVector{D, L}}
    atomic_symbols::Vector{Symbol}
    atomic_numbers::Vector{Int}
    atomic_masses::Vector{M}
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

function Base.show(io::IO, system::FastSystem)
    print(io, "FastSystem")
    show_system(io, system)
end

bounding_box(sys::FastSystem)        = sys.box
boundary_conditions(sys::FastSystem) = sys.boundary_conditions
Base.length(sys::FastSystem)         = length(sys.positions)
Base.size(sys::FastSystem)           = size(sys.positions)

species_type(sys::FS) where {FS <: FastSystem} = AtomView{FS}
Base.getindex(sys::FastSystem, index::Int)     = AtomView(sys, index)

position(s::FastSystem)       = s.positions
atomic_symbol(s::FastSystem)  = s.atomic_symbols
atomic_number(s::FastSystem)  = s.atomic_numbers
atomic_mass(s::FastSystem)    = s.atomic_masses
velocity(s::FastSystem)       = missing
data(s::FastSystem)           = missing

position(s::FastSystem, i)      = s.positions[i]
atomic_symbol(s::FastSystem, i) = s.atomic_symbols[i]
atomic_number(s::FastSystem, i) = s.atomic_numbers[i]
atomic_mass(s::FastSystem, i)   = s.atomic_masses[i]
velocity(s::FastSystem, i)      = missing
data(s::FastSystem, i)          = missing