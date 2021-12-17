using Unitful
using UnitfulAtomic
using PeriodicTable
using StaticArrays
import Base.position

export AbstractSystem
export BoundaryCondition, DirichletZero, Periodic
export species, position, velocity
export bounding_box, boundary_conditions, periodicity, n_dimensions

"""
    velocity(p)

Return the velocity of a particle `p`.
"""
function velocity end

"""
    position(p)

Return the position of a particle `p`.
"""
function position end

"""
    species(p)

Return the species of a particle `p`.
"""
function species end

#
# Identifier for boundary conditions per dimension
#
abstract type BoundaryCondition end
struct DirichletZero <: BoundaryCondition end  # Dirichlet zero boundary (i.e. molecular context)
struct Periodic <: BoundaryCondition end  # Periodic BCs


"""
    AbstractSystem{D,S}

A `D`-dimensional system comprised of particles identified by type `S`.
"""
abstract type AbstractSystem{D,S} end

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

periodicity(sys::AbstractSystem) = [isa(bc, Periodic) for bc in boundary_conditions(sys)]

# Note: Can't use ndims, because that is ndims(sys) == 1 (because of indexing interface)
n_dimensions(::AbstractSystem{D}) where {D} = D

# indexing and iteration interface...need to implement getindex and length, here are default dispatches for others
Base.size(s::AbstractSystem) = (length(s),)
Base.setindex!(::AbstractSystem, ::Int) = error("AbstractSystem objects are not mutable.")
Base.firstindex(::AbstractSystem) = 1
Base.lastindex(s::AbstractSystem) = length(s)
# default to 1D indexing
Base.iterate(S::AbstractSystem, state = firstindex(S)) =
    (firstindex(S) <= state <= length(S)) ? (@inbounds S[state], state + 1) : nothing

# TODO Support similar, push, ...

"""
    position(sys::AbstractSystem{D})
    position(sys::AbstractSystem, index)

Return a vector of positions of every particle in the system `sys`. Return type should be a vector of vectors each containing `D` elements that are `<:Unitful.Length`. If an index is passed, return only the position of the particle at that index.
"""
position(sys::AbstractSystem) = position.(sys)    # in Cartesian coordinates!
position(sys::AbstractSystem, index) = position(sys[index])

"""
    velocity(sys::AbstractSystem{D})
    velocity(sys::AbstractSystem, index)

Return a vector of velocities of every particle in the system `sys`. Return type should be a vector of vectors each containing `D` elements that are `<:Unitful.Velocity`. If an index is passed, return only the velocity of the particle at that index.
"""
velocity(sys::AbstractSystem) = velocity.(sys)    # in Cartesian coordinates!
velocity(sys::AbstractSystem, index) = velocity(sys[index])

"""
    species(sys::AbstractSystem{D,S})
    species(sys::AbstractSystem, index)

Return a vector of species of every particle in the system `sys`. Return type should be a vector of length `D` containing elements of type `S`. If an index is passed, return only the species of the particle at that index.
"""
species(sys::AbstractSystem) = species.(sys)
(species(sys::AbstractSystem{D,S}, index)::S) where {D,S} = species(sys[index])
