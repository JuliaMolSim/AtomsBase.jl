# AtomsBase

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaMolSim.github.io/AtomsBase.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaMolSim.github.io/AtomsBase.jl/dev)
[![Build Status](https://github.com/JuliaMolSim/AtomsBase.jl/workflows/CI/badge.svg)](https://github.com/JuliaMolSim/AtomsBase.jl/actions)
[![Coverage](https://codecov.io/gh/JuliaMolSim/AtomsBase.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaMolSim/AtomsBase.jl)

**AtomsBase is currently in the relatively early stages of development and we very much want developer/user input! If you think anything about it should be added/removed/changed, _please_ file an issue or chime into the discussion on an existing one!** (Look particularly for issues with the `question` label)

AtomsBase is an abstract interface for representation of atomic geometries in Julia. It aims to be a lightweight means of facilitating interoperability between various tools including...
* chemical simulation engines (e.g. density functional theory, molecular dynamics, etc.)
* file I/O with standard formats (.cif, .xyz, ...)
* numerical tools: sampling, integration schemes, etc.
* automatic differentiation and machine learning systems
* visualization (e.g. plot recipes)

Currently, the design philosophy is to be as lightweight as possible, with only
a small set of required function dispatches to make adopting the interface into
existing packages easy. We also provide a couple of
[standard flexible implementations of the interface](#atomic-systems)
that we envision to be broadly applicable.
If features beyond these are required we
we encourage developers to open PRs or provide their own implementations.

## Overview
The main abstract type introduced in AtomsBase `AbstractSystem{D}`. The `D`
parameter indicates the number of spatial dimensions in the system.
Contained inside the system are species, which may have an arbitrary type,
accessible via the `species_type(system)` function.
While AtomsBase provides some default species types (e.g. `Atom` and `AtomView`
for standard atoms) in principle no constraints are made on this species type.

The main power of the interface comes from predictable behavior of several core
functions to access information about a system and the species.
Various categories of such functions are described below.

### System geometry
Functions that need to be dispatched:
* `bounding_box(::AbstractSystem{D})::SVector{D,SVector{D,<:Unitful.Length}}`: returns `D` vectors of length `D` that describe the "box" in which the system lives
* `boundary_conditions(::AbstractSystem{D})::SVector{D,BoundaryCondition})`: returns a vector of length `D` of `BoundaryCondition` objects to describe what happens at the edges of the box

Functions that will work automatically:
* `get_periodic`: returns a vector of length `D` of `Bool`s for whether each dimension of the system has periodic boundary conditions
* `n_dimensions`: returns `D`, the number of spatial dimensions of the system

### Iteration and Indexing over systems
There is a presumption of the ability to somehow extract an individual
component (e.g. a single atom or molecule) of this system, though there are no
constraints on the type of this component. To achieve this, an `AbstractSystem`
object is expected to implement the Julia interfaces for
[iteration](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-iteration)
and [indexing](https://docs.julialang.org/en/v1/manual/interfaces/#Indexing) in
order to access representations of individual components of the system. Some
default dispatches of parts of these interfaces are already included, so the
minimal set of functions to dispatch in a concrete implementation is
`Base.getindex` and `Base.length`, though it may be desirable to customize
additional behavior depending on context.

### System state and properties
The only required properties to be specified of the system is the species
and implementations of standard functions accessing the properties of the species,
currently `position`, `velocity`, `atomic_symbol`, `atomic_mass`, `atomic_number`,
`n_dimensions`, `element`. The default dispatch of these functions onto an
`AbstractSystem` object is as a broadcast over it, which will "just work"
provided the indexing/iteration interfaces have been implemented (see above)
and the functions are defined on individual system components. Most of the property
accessors also have indexed signatures to extract a given element directly, for example:
```julia
position(sys, i) # position of `i`th particle in `sys`
```
Currently, this syntax only supports linear indexing.

To simplify working with `AtomsBase`, default implementations for systems
composed of atoms are provided, [see below](#atomic-systems)

### Struct-of-Arrays vs. Array-of-Structs
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
For concrete implementations see the section on [atomic systems](#atomic-systems) below.

### Boundary Conditions
Finally, we include support for defining boundary conditions. Currently
included are `Periodic` and `DirichletZero`. There should be one boundary
condition specified for each spatial dimension represented.

## Atomic systems
For the specific case of atomic systems provides two implementations,
as this is anticipated to be a commonly needed representation.
One implementation is a proof-of-priniciple following the struct-of-arrays approach.
The more flexible implementation is based on an array-of-structs approach
and can be easily customised, e.g. by adding custom properties or by swapping
the underlying `Atom` struct by a custom one.

### Struct of Arrays / FastSystem
The file [src/fast_system.jl](src/fast_system.jl) contains an implementation of
AtomsBase based on the struct-of-arrays approach. All species data is stored
as plain arrays, but for convenience indexing of individual atoms is supported
by a light-weight [`AtomView`](src/atomview.jl). See the implementation files
as well as the tests for how these can be used.

### Atoms and FlexibleSystem
A flexible implementation of the interface is provided by the
[`FlexibleSystem`]( src/flexible_system.jl) and the [`Atom`]( src/atom.jl) structs
for representing atomic systems.

An `Atom` object can be constructed
just by passing an identifier (e.g. symbol like `:C`, atomic number like `6`) and a vector
of positions as
```julia
atom = Atoms(:C, [0, 1, 2.]u"bohr")
```
This automatically fills the atom with standard data such as the atomic mass. Such data
can be accessed using the `AtomsBase` interface functions
such as `atomic_mass(atom)`, `position(atom)`, `velocity(atom)`, `atomic_mass(atom)`, etc.
See [src/atom.jl](src/atom.jl) for details.

Custom properties can be easily attached to an `Atom` by supplying arbitrary
keyword arguments upon construction. For example to attach a pseudopotential
for using the structure with [DFTK](https://dftk.org), construct the atom as
```julia
atom = Atoms(:C, [0, 1, 2.]u"bohr", pseudopotential="hgh/lda/c-q4")
```
which will make the pseudopotential identifier available as `atom.pseudopotential`.
Updating an atomic property proceeds similarly. E.g.
```julia
newatom = Atoms(;atom=atom, atomic_mass=13u"u")
```
makes a new carbon atom with all properties identical to `atom` (including custom ones),
but setting the `atomic_mass` to 13 units.

Once the atoms are constructed these can be assembled into a system.
For example to place a hydrogen molecule into a cubic box of `10Å` and periodic
boundary conditions, use:
```julia
bounding_box = [[10.0, 0.0, 0.0], [0.0, 10.0, 0.0], [0.0, 0.0, 10.0]]u"Å"
boundary_conditions = [Periodic(), Periodic(), Periodic()]
hydrogen = FlexibleSystem([Atom(:H, [0, 0, 1.]u"bohr"),
                           Atom(:H, [0, 0, 3.]u"bohr")],
                          bounding_box, boundary_conditions)
```
An update constructor is supported as well (see [src/flexible_system.jl](src/flexible_system.jl)).

Oftentimes more convenient are the functions
`atomic_system`, `isolated_system`, `periodic_system`,
which cover some standard atomic system setups:
```julia
# Same hydrogen system with periodic BCs:
bounding_box = [[10.0, 0.0, 0.0], [0.0, 10.0, 0.0], [0.0, 0.0, 10.0]]u"Å"
hydrogen = periodic_system([:H => [0, 0, 1.]u"bohr",
                            :H => [0, 0, 3.]u"bohr"],
                           bounding_box)

# Silicon unit cell using fractional positions
# (Common for solid-state simulations)
bounding_box = 10.26 / 2 * [[0, 0, 1], [1, 0, 1], [1, 1, 0]]u"bohr"
silicon = periodic_system([:Si =>  ones(3)/8,
                           :Si => -ones(3)/8],
                           bounding_box, fractional=true)

# Isolated H2 molecule in vacuum (Infinite box and zero dirichlet BCs)
# (Standard setup for molecular simulations)
hydrogen = isolated_system([:H => [0, 0, 1.]u"bohr",
                            :H => [0, 0, 3.]u"bohr"])

```
