#
# Implementation of AtomsBase interface in a struct-of-arrays style.
#
export FastSystem

"""
    FastSystem

A struct of arrays style prototype implementation of the AtomsBase interface. 
"""
struct FastSystem{D, TCELL, L <: Unitful.Length, M <: Unitful.Mass, S} <: SystemWithCell{D}
    cell::TCELL
    position::Vector{SVector{D, L}}
    species::Vector{S}
    mass::Vector{M}
end

# Constructor to fetch the types
function FastSystem(box::NTuple{D, <: AbstractVector}, pbc::NTuple{D, Bool}, 
                    positions, species, masses) where {D}
    cell = PeriodicCell(; cell_vectors = box, periodicity = pbc)
    FastSystem(cell, positions, species, masses)
end 

function FastSystem(cell::TCELL, positions::AbstractVector{<: SVector{D, L}}, 
                    species::AbstractVector{S}, masses) where {TCELL, D, L, S} 
    @assert D == n_dimensions(cell)
    FastSystem{D, TCELL, L, typeof(masses), S}(
        cell, positions, species, masses)
end

get_cell(sys::FastSystem) = sys.cell

# Constructor to take data from another system
function FastSystem(system::AbstractSystem)
    FastSystem(get_cell(system), position(system, :), species(system, :), mass(system, :))
end

# Convenience constructor where we don't have to preconstruct all the static stuff...
function FastSystem(particles, box, pbc)
    D = length(box)
    if !all(length.(box) .== D)
        throw(ArgumentError("Box must have D vectors of length D=$D."))
    end
    if length(pbc) != D
        throw(ArgumentError("Boundary conditions should be of length D=$D."))
    end
    if !all(n_dimensions.(particles) .== D)
        throw(ArgumentError("Particles must have positions of length D=$D."))
    end
    FastSystem(box, pbc, position.(particles), species.(particles), mass.(particles))
end

Base.length(sys::FastSystem)         = length(sys.position)
Base.size(sys::FastSystem)           = size(sys.position)

# TODO 
# species_type(::FS) where {FS <: FastSystem} = AtomView{FS}

Base.getindex(sys::FastSystem, i::Integer)  = AtomView(sys, i)

# System property access
function Base.getindex(system::FastSystem, x::Symbol)
    if x === :bounding_box
        bounding_box(system)
    elseif x === :periodicity
        periodicity(system)
    else
        throw(KeyError(x))
    end
end
Base.haskey(::FastSystem, x::Symbol) = x in (:bounding_box, :periodicity)
Base.keys(::FastSystem) = (:bounding_box, :periodicity)

# Atom and atom property access
atomkeys(::FastSystem) = (:position, :species, :mass)

hasatomkey(system::FastSystem, x::Symbol) = x in atomkeys(system)

function Base.getindex(system::FastSystem, i::Union{Integer,AbstractVector}, x::Symbol)
    getfield(system, x)[i]
end

Base.getindex(system::FastSystem, ::Colon, x::Symbol) = getfield(system, x)

position(s::FastSystem, ::Colon) = s.position
position(sys::FastSystem, i::Union{Integer, AbstractVector}) = sys.position[i]

velocity(::FastSystem, args...) = missing

mass(s::FastSystem, ::Colon) = s.mass
mass(sys::FastSystem, i::Union{Integer, AbstractVector}) = sys.mass[i]

species(s::FastSystem, ::Colon) = s.species
species(sys::FastSystem, i::Union{Integer, AbstractVector}) = sys.species[i]
