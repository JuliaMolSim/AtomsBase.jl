using Unitful
using UnitfulAtomic
using PeriodicTable
using StaticArrays
import Base.position

export SimpleAtom
export BoundaryCondition, DirichletZero, Periodic
export atomic_mass,
    atomic_number,
    atomic_symbol,
    bounding_box,
    element,
    position,
    velocity,
    boundary_conditions,
    periodic_dims
export atomic_property, has_atomic_property, atomic_propertynames
export n_dimensions


#
# Identifier for boundary conditions per dimension
#
abstract type BoundaryCondition end
struct DirichletZero <: BoundaryCondition end  # Dirichlet zero boundary (i.e. molecular context)
struct Periodic <: BoundaryCondition end  # Periodic BCs


# now the interface is just functions!
(bounding_box(sys)::SVector{D,SVector{D,<:Unitful.Length}}) where {D<:Signed} =
    error("Implement me")
(boundary_conditions(sys)::SVector{D,BoundaryCondition}) where {D<:Signed} =
    error("Implement me")
get_periodic(sys) =
    [isa(bc, Periodic) for bc in get_boundary_conditions(sys)]


# indexing and iteration interface: need to dispatch getindex, size, length, firstindex, lastindex, iterate in order for these dispatches to work
# may be a good idea also to dispatch ndims?
position(sys) = position.(sys)    # in Cartesian coordinates!
velocity(sys) = velocity.(sys)    # in Cartesian coordinates!
element(sys) = element.(sys)

# this is a concrete type, assuming we keep it should probably get moved to another file
struct SimpleAtom{D}
    position::SVector{D,<:Unitful.Length}
    element::Element
end
SimpleAtom(position, element) = SimpleAtom{length(position)}(position, element)
position(atom::SimpleAtom) = atom.position
element(atom::SimpleAtom) = atom.element

function SimpleAtom(position, symbol::Union{Integer,AbstractString,Symbol,AbstractVector})
    SimpleAtom(position, elements[symbol])
end
