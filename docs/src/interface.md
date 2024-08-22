```@meta
CurrentModule = AtomsBase
```

# Interface

This page formally defines the `AtomsBase` interface for particle systems. 
The main use-case for which the interface is designed is for systems of atoms. For this case some additional functionality is provided.
The main abstract type introduced in AtomsBase is 
- [`AbstractSystem`](@ref).

An implementation of `AbstractSystem{D}`,  
```julia 
struct ConcreteSystem{D} <: AbstractSystem{D}
   # ... 
end
```
specifies a system of particles that have a position in `D` dimensional Euclidean space. That is, the parameter `D` indicates the number of spatial dimensions into which each particle is embedded. 
A particle will normally also have additional properties such as mass, charge, chemical species, etc, but those are ignored in the interpretation of `D`.

The interface aims to achieve predictable behavior of several core functions to access information about a particle system. 
- [Core Interface](@ref) : this is a minimal read-only core of the AtomsBase interface and must be implemented by a subtype of `AtomsBase.AbstractSystem` to enable the implementation to be used across the AtomsBase ecosystem. 
- [Setter Interface](@ref) : (optional) It is strongly recommended that implementations requiring mutation follow this interface. 
- [Optional properties interface](@ref) : (optional) For some use-cases (e.g. managing datasets) it can be useful to allow a system to store more general properties about a particle system (or the individual particles themselves). The *optional properties interface* specifies the recommended interface for such as scenario. 



## Core Interface

A minimal implementation of the `AtomsBase` interface is read-only and must overload the functions listed as follows. 

- `Base.length(system)`
- `Base.getindex(system, i)` 
- [`AtomsBase.position(system, i)`](@ref)
- [`AtomsBase.mass(system, i)`](@ref)
- [`AtomsBase.species(system, i)`](@ref)

Methods for `bounding_box` and `periodicity` are provided automatically if the system supports the cell interface. A system implementation that implements the cell interface should subtype `SystemWithCell{D}` instead of `AbstractSystem{D}`. In this case, one needs to instead overload
- [`AtomsBase.get_cell(system)`](@ref)

The linked documentation and following paragraphs give additional information about each of those functions.


### System properties

A system is specified by a computational domain and particles within that domain. 
System properties are properties of the entire particle system, as opposed to 
properties of individual particles. 

- `Base.length(system)`  : return an `Integer`, the number of particles in the system; if the system describes a periodic cell, then the number of particles in one period of the cell is returned.
- [`AtomsBase.bounding_box(system)`](@ref) : returns `NTuple{D, SVector{D, T}}` the cell vectors that specify the computational domain if it is finite. For open systems, the return values of [`AtomsBase.bounding_box`](@ref) are unspecified.
- [`AtomsBase.periodicity(system)`](@ref) : returns `NTuple{D, Bool}`, booleans that specify whether the system is periodic in the direction of the `D` cell vectors provided by `bounding_box`. For open systems `periodicity` must return `(false, ..., false)`.

It is recommended that the implementation of [`bounding_box`](@ref) and [`periodicity`](@ref) is replaced with an implementation of 
- [`AtomsBase.get_cell(system)`](@ref) : returns an object `cell` that specifies the computational cell. If that object implements `AtomsBase.bounding_box(cell)` and `AtomsBase.periodicity(cell)`, then `AtomsBase.bounding_box(system)` and `AtomsBase.periodicity(systems)` are provided automatically, provided that `system <: AbstractSystemWithCell{D}`.

Two recommended general purpose implementations of computational cells are provided as part of `AtomsBase`: 
- [`PCell`](@ref) : implementation of a periodic parallelepiped shaped cell
- [`OpenSystemCell`](@ref) : implementation of a cell describing an open system (infinite in all directions)


### Particle properties 

- [`position(system, i::Integer)`](@ref) : return an `SVector{D, <: Unitful.Length}` enconding the position of the ith particle
- [`mass(system, i::Integer)`](@ref) : return a `<: Unitful.Mass`, the mass of the ith particle
- [`species(system, i::Integer)`](@ref) : return an object that defines the particle species (kind, type, ...). In most cases this should be a categorical variable on which no arithmetic is defined. In atomistic simulation this is normally the chemical element (cf. [`AtomsBase.ChemicalSpecies`](@ref)), possibly augmented with additional information about the atom. But the interface does not require use of any specific type to define the particle species.

For each of `property in [position, mass, species]` there must also be defined 
- `property(system, inds::AbstractVector{<: Integer})` : return a list (e.g. `AbstractVector`) of the requested property of the particles indexed by `inds`;  
- `property(system, :)` : return a list of the requested property for all particles in the system.

### Iteration and Indexing over systems

There is a presumption of the ability to somehow extract an individual
component (e.g. a single atom or molecule) of this system, though there are no
constraints on the type of this component. To achieve this, an [`AbstractSystem`](@ref)
object is expected to implement the Julia interfaces for
[iteration](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-iteration)
and [indexing](https://docs.julialang.org/en/v1/manual/interfaces/#Indexing) in
order to access representations of individual components of the system. Some
default dispatches of parts of these interfaces are already included, so the
minimal set of functions to dispatch in a concrete implementation is
`Base.getindex` and `Base.length`, though it may be desirable to customize
additional behavior depending on context.


## Setter Interface

The optional setter / mutation interface consists of the following functions to be overloaded. 

- [`set_bounding_box!(system, bb)`](@ref) 
- [`set_periodicity!(system, pbc)`](@ref) 
- [`set_cell!(system, cell)`](@ref) 
- [`set_position!(system, i, x)`](@ref) 
- [`set_mass!(system, i, x)`](@ref)
- [`set_species!(system, i, x)`](@ref) 
- `deleteat!(system, i)` : delete atoms `i` (or atoms `i` if a list of `":`)
- `append!(system1, system2)` : append system 2 to system 1, provided they are "compatible". 

### Notes

- For each of the particle property setters, `i` may be an `Integer`, an `AbstractVector{<: Integer}` or `:`.
- If `set_cell!` is implemented, then for `system <: SystemWithCell`, methods for `set_bounding_box!` and `set_periodicity!` are provided.


## Optional properties interface

For some use-cases (e.g. managing datasets) it can be useful to allow a system to store more general properties about a particle system or even the individual particles themselves. The *optional properties interface* specifies the recommended interface for such as scenario. The [Tutorial](@ref) provides a more detailed discussion and exmaples how these can be used. The prototype implementations also provide further details.

An implementation that wants to support the AtomsBase optional properties interface should implement the following methods: 

System properties:
- `getindex`
- `haskey`
- `get`
- `keys`
- `pairs`

Particle properties
- `atomkeys` 
- `hasatomkey` 



## Future Interface Extensions

The AtomsBase developers are considering extending the AtomsBase interface with additional functions. Developers may keep this in mind during development. Issues or discussions related to this are welcome. 

Here we maintain a list of possibly future interface functions:

- `charge` 
- `charge_dipole` 
- `velocity`
- `momentum` 
- `spin`
- `magnetic_moment`
