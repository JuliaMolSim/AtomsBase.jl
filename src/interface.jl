using Unitful
using UnitfulAtomic
using PeriodicTable

export AbstractElement, AbstractParticle, AbstractAtom, AbstractSystem
export Element
export BoundaryCondition, DirichletZero, Periodic
export get_atomic_mass, get_atomic_number, get_atomic_symbol,
    get_box, get_element, get_position, get_velocity,
    get_boundary_conditions, get_periodic
export get_atomic_property, has_atomic_property, atomic_propertynames
export n_dimensions


abstract type AbstractElement end
struct Element <: AbstractElement
    data::PeriodicTable.Element
end
Element(symbol::Union{Symbol,Integer,AbstractString}) = Element(PeriodicTable.elements[symbol])
Base.show(io::IO, elem::Element) = print(io, "Element(", get_atomic_symbol(elem), ")")

# These are always only read-only ... and allow look-up into a database
get_atomic_symbol(el::Element) = el.data.symbol
get_atomic_number(el::Element) = el.data.number
get_atomic_mass(el::Element)   = el.data.atomic_mass



#
# A distinguishable particle, can be anything associated with coordinate
# information (position, velocity, etc.)
# most importantly: Can have any identifier type
#
# IdType:  Type used to identify the particle
#
abstract type AbstractParticle end
get_velocity(::AbstractParticle)::AbstractVector{<: Unitful.Velocity} = missing
get_position(::AbstractParticle)::AbstractVector{<: Unitful.Length}   = error("Implement me")
get_element(::AbstractParticle)::AbstractElement = error("Implement me")


#
# The atom type itself
#     - The atom interface is read-only (to allow as simple as possible implementation)
#       Writability may be supported in derived or concrete types.
#     - The inferface is only in Cartesian coordinates.
#     - Has atom-specific defaults (i.e. assumes every entity represents an atom or ion)
#
abstract type AbstractAtom <: AbstractParticle end
get_element(::AbstractAtom)::Element = error("Implement me")


# Extracting things ... it might make sense to make some of them writable in concrete
# implementations, therefore these interfaces are forwarded from the Element object.
get_atomic_symbol(atom::AbstractAtom) = get_atomic_symbol(get_element(atom))
get_atomic_number(atom::AbstractAtom) = get_atomic_number(get_element(atom))
get_atomic_mass(atom::AbstractAtom)   = get_atomic_mass(get_element(atom))

# Custom atomic properties:
get_atomic_property(::AbstractAtom, ::Symbol, default=missing) = default
has_atomic_property(atom::AbstractAtom, property::Symbol) = !ismissing(get_atomic_property(atom, property))
atomic_propertynames(::AbstractAtom) = Symbol[]

#
# Identifier for boundary conditions per dimension
#
abstract type BoundaryCondition end
struct DirichletZero <: BoundaryCondition end  # Dirichlet zero boundary (i.e. molecular context)
struct Periodic      <: BoundaryCondition end  # Periodic BCs


#
# The system type
#     Again readonly.
#
abstract type AbstractSystem{AT <: AbstractParticle} <: AbstractVector{AT} end
get_box(::AbstractSystem)::Vector{<:AbstractVector} = error("Implement me")
get_boundary_conditions(::AbstractSystem)::AbstractVector{BoundaryCondition} = error("Implement me")
get_periodic(sys::AbstractSystem) = [isa(bc, Periodic) for bc in get_boundary_conditions(sys)]

# Note: Can't use ndims, because that is ndims(sys) == 1 (because of AbstractVector interface)
n_dimensions(sys::AbstractSystem) = length(get_boundary_conditions(sys))

Base.getindex(::AbstractSystem{AT}, ::Int)::AT  = error("Implement me")
Base.getindex(::AbstractSystem, ::AbstractArray)::AbstractSystem  = error("Implement me")
Base.size(::AbstractSystem)             = error("Implement me")
Base.setindex!(::AbstractSystem, ::Int) = error("AbstractSystem objects are not mutable.")

# TODO Support similar, push, ...

# Some implementations might prefer to store data in the System as a flat list and
# expose Atoms as a view. Therefore these functions are needed. Of course this code
# should be autogenerated later on ...
get_position(sys::AbstractSystem) = get_position.(sys)    # in Cartesian coordinates!
get_velocity(sys::AbstractSystem) = get_velocity.(sys)    # in Cartesian coordinates!
get_element(sys::AbstractSystem)  = get_element.(sys)

#
# Extra stuff only for Systems composed of atoms
#
get_atomic_symbol(sys::AbstractSystem{<: AbstractAtom}) = get_atomic_symbol.(sys)
get_atomic_number(sys::AbstractSystem{<: AbstractAtom}) = get_atomic_number.(sys)
get_atomic_mass(sys::AbstractSystem{<: AbstractAtom})   = get_atomic_mass.(sys)
get_atomic_property(sys::AbstractSystem{<: AbstractAtom}, property::Symbol)::Vector{Any} = get_atomic_property.(sys, property)
atomic_propertiesnames(sys::AbstractSystem{<: AbstractAtom}) = unique(sort(atomic_propertynames.(sys)))

# Just to make testing a little easier for now
function Base.show(io::IO, ::MIME"text/plain", part::AbstractParticle)
    print(io, "Particle(", get_element(part), ") @ ", get_position(part))
end
function Base.show(io::IO, ::MIME"text/plain", part::AbstractAtom)
    print(io, "Atom(", get_atomic_symbol(part), ") @ ", get_position(part))
end
function Base.show(io::IO, mime::MIME"text/plain", sys::AbstractSystem)
    println(io, "System:")
    println(io, "    BCs:        ", get_boundary_conditions(sys))
    println(io, "    Box:        ", get_box(sys))
    println(io, "    Particles:  ")
    for particle in sys
        Base.show(io, mime, particle)
        println(io)
    end
end
