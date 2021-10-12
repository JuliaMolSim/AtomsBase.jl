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

Currently, the design philosophy is to be as lightweight as possible, with only a small set of required function dispatches. We will also provide a couple of standard concrete implementations of the interface that we envision could be broadly applicable, but encourage developers to provide their own implementations as needed in new or existing packages.

## Overview
AtomsBase defines a few abstract types used for specifying an atomic system. We will describe them briefly here, from the "top down." Users and/or prospective developers may also find `implementation_simple.jl` a useful reference for a simple concrete implementation of the interface.

**A remark on SoA vs. AoS:** The "struct-of-arrays" (SoA) vs. "array-of-structs" (AoS) is a common design dilemma in representations of systems such as these. We have deliberately designed this interface to be _agnostic_ to how a concrete implementation chooses to structure its data. Some specific notes regarding how implementations might differ for these two paradigms are included below.

A way to think about this broadly is that the difference amounts to the ordering of function calls. For example, to get the position of a single particle in an AoS implementation, the explicit funciton chaining would be `get_position(getindex(sys))` (i.e. extract the single struct representing the particle of interest and query its position), while for SoA, one should prefer `getindex(get_position(sys))` (extract the array of positions, then index into it for a single particle). The beauty of an abstract interface in Julia is that these details can be, in large part, abstracted away through method dispatch such that the end user sees the same expected behavior irrespective of how things are implemented "under the hood."

### System
An object describing a system should be a subtype of `AbstractSystem` and will in general store identifiers, positions, and (if relevant) velocities of the particles that make it up, as well as a set of coordinate bounds.

An `AbstractSystem` takes a type parameter (which must be `<:AbstractParticle`, see below) to indicate what types of particles these are, and requires dispatch of the following functions:
* `get_box(::AbstractSystem)::Vector{<:AbstractVector}`: should return a set of basis vectors describing the boundaries of the coordinates in which the system resides
* `get_boundary_conditions(::AbstractSystem)::AbstractVector{BoundaryCondition}`: returns the boundary conditions corresponding to each spatial dimension of the system (see below for more on the `BoundaryCondition` type)

`AbstractSystem` subtypes `AbstractVector`, thus the following functions must also be dispatched:
* `Base.getindex(::AbstractSystem, ::Int)`
* `Base.size(::AbstractSystem)`

By default, the `get_position` and `get_velocity` functions dispatch onto `AbstractSystem` objects as a broadcast over the system (e.g. `get_position(sys::AbstractSystem) = get_position.(sys)`, invoking the dispatch of `get_position` onto the `AbstractParticle` type parameter of the system). In an SoA implementation, custom dispatches should probably be included to avoid the construction of the particle objects.

**A remark on fractional coordinates:** In many contexts, it is desirable to work with fractional coordinates, i.e. unitless multiples of some reference coordinate system (typically this reference is what would be returned by the `get_box` function above). Because a focus of this interface is interoperability and unitless, non-Cartesian coordinates introduce ambiguity, we've chosen to impose that coordinates returned by functions in the interface be unitful quantities in a Cartesian frame. Of course, a concrete implementation of the interface could (and likely would need to) also dispatch additional functions for working with fractional coordinates.

### Particles
Particle objects are subtypes of `AbstractParticle`, and also take a type parameter that is `<:AbstractElement` (see below) to indicate how particles are identified.

In the SoA case, particle objects would only ever be explicitly constructed when `getindex` is invoked on the system, as a "view" into the system.

Particle objects should dispatch methods of the following functions:
* `get_position(::AbstractParticle)::AbstractVector{<: Unitful.Length}`
* `get_element(::AbstractParticle)::AbstractElement`

And, optionally, 
* `get_velocity(::AbstractParticle)::AbstractVector{<: Unitful.Velocity}`, which defaults to returning `nothing` if not dispatched.
### Elements
Subtypes of `AbstractElement` serve as identifiers of particles. As the name suggests, a common case would be a chemical element (e.g. for a DFT simulation). However, it could also contain more detailed isotopic/spin information if that is necessary, or be a molecule (e.g. in MD), or even a much larger-scale object!

For simulation purposes, the utility of this object would be to serve as a sufficiently specific "index" into a database of simulation parameters (e.g. a pseudopotential library for DFT, or interparticle potential parameters for MD). Because we envision a chemical element being an extremely common case, we provide an explicit subtype in the form of `Element`, which makes use of [PeriodicTable.jl](https://github.com/JuliaPhysics/PeriodicTable.jl) to access information such as atomic numbers and masses.

### Boundary Conditions
Finally, we include support for defining boundary conditions. Currently included are `Periodic` and `DirichletZero`. There should be one boundary condition specified for each spatial dimension represented.