import Base.position

export AbstractSystem
export BoundaryCondition, DirichletZero, Periodic
export bounding_box, boundary_conditions, periodicity, n_dimensions, species_type
export position, velocity, element, atomic_mass, atomic_number, atomic_symbol

#
# Identifier for boundary conditions per dimension
#
abstract type BoundaryCondition end
struct DirichletZero <: BoundaryCondition end  # Dirichlet zero boundary (i.e. molecular context)
struct Periodic <: BoundaryCondition end  # Periodic BCs

#
# Species property accessors
#
"""The element corresponding to a species/atom (or missing)."""
function element end

"""The position of a species/atom."""
function position end

"""The velocity of a species/atom (or missing)."""
function velocity end

"""The mass of a species/atom."""
function atomic_mass end

"""The atomic number of a species/atom (or missing)."""
function atomic_number end

"""The symbol corresponding to a species/atom (or missing)."""
function atomic_symbol end


#
# Abstract system
#
"""
    AbstractSystem{D}

A `D`-dimensional system.
"""
abstract type AbstractSystem{D} end

"""
    bounding_box(sys::AbstractSystem{D})

Return a vector of length `D` of vectors of length `D` that describe the "box" in which the system `sys` is defined.
"""
function bounding_box end

"""
    boundary_conditions(sys::AbstractSystem{D})

Return a vector of length `D` of `BoundaryCondition` objects, one for each direction described by `bounding_box(sys)`.
"""
function boundary_conditions end

"""
    species_type(::AbstractSystem)

Return the type used to represent a species or atom.
"""
function species_type end

periodicity(sys::AbstractSystem) = [isa(bc, Periodic) for bc in boundary_conditions(sys)]

"""
    n_dimensions(::AbstractSystem)
    n_dimensions(atom)

Return number of dimensions.
"""
n_dimensions(::AbstractSystem{D}) where {D} = D
# Note: Can't use ndims, because that is ndims(sys) == 1 (because of indexing interface)

# indexing and iteration interface...need to implement getindex and length, here are default dispatches for others
Base.size(s::AbstractSystem) = (length(s),)
Base.setindex!(::AbstractSystem, ::Int) = error("AbstractSystem objects are not mutable.")
Base.firstindex(::AbstractSystem) = 1
Base.lastindex(s::AbstractSystem) = length(s)
# default to 1D indexing
Base.iterate(sys::AbstractSystem, state = firstindex(sys)) =
    (firstindex(sys) <= state <= length(sys)) ? (@inbounds sys[state], state + 1) : nothing

# TODO Support similar, push, ...

#
# Species property accessors from system
#
"""
    position(sys::AbstractSystem{D})
    position(sys::AbstractSystem, index)

Return a vector of positions of every particle in the system `sys`. Return type
should be a vector of vectors each containing `D` elements that are
`<:Unitful.Length`. If an index is passed, return only the position of the
particle at that index.
"""
position(sys::AbstractSystem)        = position.(sys)    # in Cartesian coordinates!
position(sys::AbstractSystem, index) = position(sys[index])



"""
    velocity(sys::AbstractSystem{D})
    velocity(sys::AbstractSystem, index)

Return a vector of velocities of every particle in the system `sys`. Return
type should be a vector of vectors each containing `D` elements that are
`<:Unitful.Velocity`. If an index is passed, return only the velocity of the
particle at that index.
"""
velocity(sys::AbstractSystem)        = velocity.(sys)    # in Cartesian coordinates!
velocity(sys::AbstractSystem, index) = velocity(sys[index])


"""
    atomic_mass(sys::AbstractSystem)
    atomic_mass(sys::AbstractSystem, i)

Vector of atomic masses in the system `sys` or the atomic mass of the `i`th particle in `sys`.
The elements are `<: Unitful.Mass`.
"""
atomic_mass(sys::AbstractSystem)        = atomic_mass.(sys)
atomic_mass(sys::AbstractSystem, index) = atomic_mass(sys[index])


"""
    atomic_symbol(sys::AbstractSystem)
    atomic_symbol(sys::AbstractSystem, i)

Vector of atomic symbols in the system `sys` or the atomic symbol of the `i`th particle in `sys`.
"""
atomic_symbol(sys::AbstractSystem)        = atomic_symbol.(sys)
atomic_symbol(sys::AbstractSystem, index) = atomic_symbol(sys[index])

"""
    atomic_number(sys::AbstractSystem)
    atomic_number(sys::AbstractSystem, i)

Vector of atomic numbers in the system `sys` or the atomic number of the `i`th particle in `sys`.
"""
atomic_number(sys::AbstractSystem)        = atomic_number.(sys)
atomic_number(sys::AbstractSystem, index) = atomic_number(sys[index])
