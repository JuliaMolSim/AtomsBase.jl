#
# Implementation of AtomsBase interface in a struct-of-arrays style.
#
export FastSystem

"""
    FastSystem

A struct of arrays style prototype implementation of the AtomsBase interface. 
"""
struct FastSystem{D, TCELL, L <: Unitful.Length, M <: Unitful.Mass, S} <: AbstractSystem{D}
    cell::TCELL
    position::Vector{SVector{D, L}}
    species::Vector{S}
    mass::Vector{M}
end

# Constructor to fetch the types
function FastSystem(box::AUTOBOX, 
                    pbc::AUTOPBC, 
                    positions, species, masses)
    cϵll = PeriodicCell(; cell_vectors = box, periodicity = pbc)
    FastSystem(cϵll, positions, species, masses)
end 

function FastSystem(cϵll::TCELL, positions::AbstractVector{<: SVector{D, L}}, 
                    species::AbstractVector{S}, masses) where {TCELL, D, L, S} 
    if D != n_dimensions(cϵll)
        throw(ArgumentError("Cell dimension D=$(n_dimensions(cϵll)) does not match particle dimension D=$D."))
    end
    FastSystem{D, TCELL, L, typeof(masses), S}(
        cϵll, positions, species, masses)
end

cell(sys::FastSystem) = sys.cell

# Constructor to take data from another system
function FastSystem(system::AbstractSystem)
    FastSystem(cell(system), position(system, :), species(system, :), mass(system, :))
end

# Convenience constructor where we don't have to preconstruct all the static stuff...
function FastSystem(particles, box::AUTOBOX, pbc::AUTOPBC)
    box1 = _auto_cell_vectors(box)
    pbc1 = _auto_pbc(pbc, box1)
    D = length(box1)
    if !all(length.(box1) .== D)
        throw(ArgumentError("Box must have D vectors of length D=$D."))
    end
    if length(pbc1) != D
        throw(ArgumentError("Boundary conditions should be of length D=$D."))
    end
    if !all(n_dimensions.(particles) .== D)
        throw(ArgumentError("Particles must have positions of length D=$D."))
    end
    FastSystem(box1, pbc1, position.(particles), species.(particles), mass.(particles))
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

mass(s::FastSystem, ::Colon) = s.mass
mass(sys::FastSystem, i::Union{Integer, AbstractVector}) = sys.mass[i]

species(s::FastSystem, ::Colon) = s.species
species(sys::FastSystem, i::Union{Integer, AbstractVector}) = sys.species[i]
