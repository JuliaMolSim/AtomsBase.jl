```@meta
CurrentModule = AtomsBase.Implementation
```

# Prototype Implementations 

`AtomsBase` provides two prototype implementations of `AbstractSystem{D}`. They are not automatically exported. To use those implementations one can first call 
```julia
using AtomsBase.Implementation
```

The two implementations are 
- [`FlexibleSystem`](@ref)
- [`FastSystem`](@ref)
and are briefly discussed in more detail in the remainder of this page. 

## Struct-of-Arrays vs. Array-of-Structs

The "struct-of-arrays" (SoA) vs. "array-of-structs" (AoS) is a common design
dilemma in representations of systems of particles. AtomsBase is deliberately
designed to be _agnostic_ to how a concrete implementation
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

### Struct of Arrays / FastSystem

The file [`fast_system.jl`](https://github.com/JuliaMolSim/AtomsBase.jl/blob/master/src/implementation/fast_system.jl) contains an implementation of
AtomsBase based on the struct-of-arrays approach. All species data is stored
as plain arrays, but for convenience indexing of individual atoms is supported
by a light-weight [`AtomView`](@ref). See the implementation files
as well as the tests for how these can be used.

### Atoms and FlexibleSystem

A flexible implementation of the interface is provided by the
[`FlexibleSystem`](@ref) and the [`Atom`](@ref) structs
for representing atomic systems.These are discussed in detail in the tutorial. 
