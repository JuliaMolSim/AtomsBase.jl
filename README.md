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

Currently, the design philosophy is to be as lightweight as possible, with only a small set of required function dispatches to make adopting the interface into existing packages easy. We also provide a couple of standard concrete implementations of the interface that we envision could be broadly applicable, but encourage developers to provide their own implementations as needed in new or existing packages.

## Overview
The main abstract type introduced in AtomsBase `AbstractSystem{D,S}`. The `D` parameter indicates the number of spatial dimensions in the system, and `S` indicates the type identifying an individual species in this system.

The main power of the interface comes from predictable behavior of several core functions to access information about a system. Various categories of such functions are described below.

### System geometry
Functions that need to be dispatched:
* `bounding_box(::AbstractSystem{D})::SVector{D,SVector{D,<:Unitful.Length}}`: returns `D` vectors of length `D` that describe the "box" in which the system lives
* `boundary_conditions(::AbstractSystem{D})::SVector{D,BoundaryCondition})`: returns a vector of length `D` of `BoundaryCondition` objects to describe what happens at the edges of the box

Functions that will work automatically:
* `get_periodic`: returns a vector of length `D` of `Bool`s for whether each dimension of the system has periodic boundary conditions
* `n_dimensions`: returns `D`, the number of spatial dimensions of the system

### Iteration and Indexing over systems
There is a presumption of the ability to somehow extract an individual component (e.g. a single atom or molecule) of this system, though there are no constraints on the type of this component. To achieve this, an `AbstractSystem` object is expected to implement the Julia interfaces for [iteration](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-iteration) and [indexing](https://docs.julialang.org/en/v1/manual/interfaces/#Indexing) in order to access representations of individual components of the system. Some default dispatches of parts of these interfaces are already included, so the minimal set of functions to dispatch in a concrete implementation is `Base.getindex` and `Base.length`, though it may be desirable to customize additional behavior depending on context.

### System state and properties
The only required properties to be specified of the system is the species of each component of the system and the positions and velocities associated with each component. These are accessed through the functions `species`, `position`, and `velocity`, respectively. The default dispatch of these functions onto an `AbstractSystem` object is as a broadcast over it, which will "just work" provided the indexing/iteration interfaces have been implemented (see above) and the functions are defined on individual system components.

As a concrete example, AtomsBase provides the `StaticAtom` type as this is anticipated to be a commonly needed representation. Its implementation looks as follows:
```julia
struct StaticAtom{D,L<:Unitful.Length}
    position::SVector{D,L}
    element::Element
end
StaticAtom(position, element) = StaticAtom{length(position)}(position, element)
position(atom::StaticAtom) = atom.position
species(atom::StaticAtom) = atom.element
```
Note that the default behavior of `velocity` is to return `missing`, so it doesn't need to be explicitly dispatched here.

The two sample implementations provided in this repo are both "composed" of `StaticAtom` objects; refer to them as well as `sandbox/aos_vs_soa.jl` to see how this can work in practice.
### Struct-of-Arrays vs. Array-of-Structs
The "struct-of-arrays" (SoA) vs. "array-of-structs" (AoS) is a common design dilemma in representations of systems such as these. We have deliberately designed this interface to be _agnostic_ to how a concrete implementation chooses to structure its data. Some specific notes regarding how implementations might differ for these two paradigms are included below.

A way to think about this broadly is that the difference amounts to the ordering of function calls. For example, to get the position of a single particle in an AoS implementation, the explicit function chaining would be `position(getindex(sys))` (i.e. extract the single struct representing the particle of interest and query its position), while for SoA, one should prefer an implementation like `getindex(position(sys))` (extract the array of positions, then index into it for a single particle). The beauty of an abstract interface in Julia is that these details can be, in large part, abstracted away through method dispatch such that the end user sees the same expected behavior irrespective of how things are implemented "under the hood."

To demonstrate this, we provide two simple concrete implementations of the interface in `implementation_soa.jl` and `implementation_aos.jl` to show how analogous systems could be constructed within these paradigms (including the `getindex` implementations mentioned above). See also `sandbox/aos_vs_soa.jl` for how they can actually be constructed and queried.

### Boundary Conditions
Finally, we include support for defining boundary conditions. Currently included are `Periodic` and `DirichletZero`. There should be one boundary condition specified for each spatial dimension represented.
