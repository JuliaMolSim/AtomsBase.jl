# Overview
The main abstract type introduced in AtomsBase is [`AbstractSystem{D}`](@ref). The `D`
parameter indicates the number of spatial dimensions in the system.
Contained inside the system are species, which may have an arbitrary type,
accessible via the `species_type(system)` function.
While AtomsBase provides some default species types (e.g. `Atom` and `AtomView`
for standard atoms) in principle no constraints are made on this species type.

The main power of the interface comes from predictable behavior of several core
functions to access information about a system and the species.
Various categories of such functions are described below.

## System geometry
Functions that need to be dispatched:
* `bounding_box(::AbstractSystem{D})::SVector{D,SVector{D,<:Unitful.Length}}`: returns `D` vectors of length `D` that describe the "box" in which the system lives
* `boundary_conditions(::AbstractSystem{D})::SVector{D,BoundaryCondition})`: returns a vector of length `D` of `BoundaryCondition` objects to describe what happens at the edges of the box

Functions that will work automatically:
* `periodicity`: returns a vector of length `D` of `Bool`s for whether each dimension of the system has periodic boundary conditions
* `n_dimensions`: returns `D`, the number of spatial dimensions of the system

## Iteration and Indexing over systems
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

## System state and properties
The only required properties to be specified of the system is the species
and implementations of standard functions accessing the properties of the species,
currently
  - Geometric information: [`position`](@ref), [`velocity`](@ref), [`n_dimensions`](@ref)
  - Atomic information: [`atomic_symbol`](@ref), [`atomic_mass`](@ref), [`atomic_number`](@ref), [`element`](@ref)
  - Atomic and system property accessors: `getindex`, `haskey`, `get`, `keys`, `pairs`
Based on these methods respective equivalent methods acting
on an `AbstractSystem` will be automatically available, e.g. using the iteration
interface of the `AbstractSystem` (see above). Most of the property accessors on the
`AbstractSystem` also have indexed signatures to extract data from a particular species
directly, for example:
```julia
position(sys, i) # position of `i`th particle in `sys`
```
Currently, this syntax only supports linear indexing.

To simplify working with `AtomsBase`, default implementations for systems
composed of atoms are provided (see [Tutorial](@ref)).

## Struct-of-Arrays vs. Array-of-Structs
The "struct-of-arrays" (SoA) vs. "array-of-structs" (AoS) is a common design
dilemma in representations of systems such as these. We have deliberately
designed this interface to be _agnostic_ to how a concrete implementation
chooses to structure its data. Some specific notes regarding how
implementations might differ for these two paradigms are included below.

A way to think about this broadly is that the difference amounts to the
ordering of function calls. For example, to get the position of a single
particle in an AoS implementation, the explicit function chaining would be
`position(getindex(sys))` (i.e. extract the single struct representing the
particle of interest and query its position), while for SoA, one should prefer
an implementation like `getindex(position(sys))` (extract the array of
positions, then index into it for a single particle). The beauty of an abstract
interface in Julia is that these details can be, in large part, abstracted away
through method dispatch such that the end user sees the same expected behavior
irrespective of how things are implemented "under the hood".

## Boundary Conditions
Finally, we include support for defining boundary conditions. Currently
included are `Periodic` and `DirichletZero`. There should be one boundary
condition specified for each spatial dimension represented.

## Atomic system
Since we anticipate atomic systems to be a commonly needed representation,
`AtomsBase` provides two flexible implementations for this setting.
One implementation follows the struct-of-arrays approach introducing the `AtomView`
type to conveniently expose atomic data.
The more flexible implementation is based on an array-of-structs approach
and can be easily customised, e.g. by adding custom properties or by swapping
the underlying `Atom` struct by a custom one.
In both cases the respective datastructures can be used either fully
or in parts in downstream packages and we hope these to develop into universally
useful types within the Julia ecosystem over time.

### Struct of Arrays / FastSystem
The file [src/fast_system.jl](https://github.com/JuliaMolSim/AtomsBase.jl/blob/master/src/fast_system.jl) contains an implementation of
AtomsBase based on the struct-of-arrays approach. All species data is stored
as plain arrays, but for convenience indexing of individual atoms is supported
by a light-weight `AtomView`. See the implementation files
as well as the tests for how these can be used.

### Atoms and FlexibleSystem
A flexible implementation of the interface is provided by the
`FlexibleSystem` and the `Atom` structs
for representing atomic systems.
These are discussed in detail in [Tutorial](@ref).
