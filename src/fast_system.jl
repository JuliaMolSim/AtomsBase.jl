#
# Implementation of AtomsBase interface in a struct-of-arrays style.
#
export FastSystem

struct FastSystem{D, TCELL, L <: Unitful.Length, M <: Unitful.Mass} <: SystemWithCell{D, TCELL}
    cell::TCELL 
    chemical_element::Vector{ChemicalElement}
    position::Vector{SVector{D, L}}
    atomic_mass::Vector{M}
end

# Constructor to fetch the types
function FastSystem(cell::TCELL, positions, atomic_ids, atomic_masses) where {TCELL}
    D = n_dimensions(cell)  
    L = eltype(eltype(positions)) 
    M = eltype(atomic_masses)
    chemical_elements = ChemicalElement.(atomic_ids)
    FastSystem{D, TCELL, L, M}(
        cell, chemical_elements, positions, atomic_masses
    )
end

# Constructor to take data from another system
function FastSystem(system::SystemWithCell)
    FastSystem(get_cell(system), 
               position(system),
               atomic_number(system), 
               atomic_mass(system))
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
    cell = PCell(; cell_vectors = box, 
                   boundary_conditions = boundary_conditions)
    FastSystem(cell, position.(particles), 
                atomic_number.(particles), 
                atomic_mass.(particles))
end

get_cell(sys::FastSystem) = sys.cell

Base.length(sys::FastSystem)         = length(sys.position)
Base.size(sys::FastSystem)           = size(sys.position)

species_type(::FS) where {FS <: FastSystem} = AtomView{FS}
Base.getindex(sys::FastSystem, i::Integer)  = AtomView(sys, i)

position(s::FastSystem)       = s.position
atomic_symbol(s::FastSystem)  = s.chemical_element
atomic_number(s::FastSystem)  = getfield.(s.chemical_element, :atomic_number)  #  reinterpret(UInt8, s.chemical_element)
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
function Base.getindex(system::FastSystem, i::Union{Integer,AbstractVector}, x::Symbol)
    getfield(system, x)[i]
end
Base.getindex(system::FastSystem, ::Colon, x::Symbol) = getfield(system, x)
