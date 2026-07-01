
```@meta
CurrentModule = AtomsBase
```

# Utilities

This page documents some utilities that AtomsBase provides in addition to the interface. This documentation is preliminary. PRs to improve it are welcome. 

## Cell Types 

As of AtomsBase 0.4 we recommend that implementations of the interface specify a computational cell type. To simplify this, AtomsBase provides two prototype implementations: 

- [`PeriodicCell`](@ref) : implements the standard parallepiped shaped cell defined through three cell vectors and periodicity (true or false) along each cell vector.
- [`IsolatedCell`](@ref) : implements a computational cell that is open (infinite) in all directions, i.e. the entire space.


## Chemical Species 

The function [`AtomsBase.species(sys, i)`](@ref) return the particle species of a particle (or multiple particles). AtomsBase does not enforce any specific type to be returned. However, it is recommended that systems describing atomic structures use - whenever possible - the `ChemicalSpecies` type that is implemented as part of `AtomsBase`.

- [`ChemicalSpecies`](@ref) : a prototype implementation and recommended default for the species of an atom.

!!! note "`==` versus `isequal` for `ChemicalSpecies`"
    `ChemicalSpecies` distinguishes two notions of comparison. `==` is a *matching* relation: an unspecified isotope or atom name acts as a wildcard, so e.g. `ChemicalSpecies(:C) == ChemicalSpecies(:C13)` is `true`. This is handy for queries (e.g. "is this atom carbon?"), but it is not a strict equality and is not even transitive (`:C == :C13` and `:C == :C12`, yet `:C12 != :C13`).
    In contrast `isequal` (with the corresponding `hash`) is *strict* equality of all fields, and `isless` provides a strict total order. These are the well-behaved counterparts used by `sort`, `Set`, `Dict` and `unique`, so `isequal(ChemicalSpecies(:C), ChemicalSpecies(:C13))` is `false`.

## Convenience functions

AtomsBase provides a number of convenience utilities that should work for any system that implements the AtomsBase interface. If they not work as expected this is likely a bug and should be reported as an issue. 

- `atomic_mass = mass` : deprecated 
- [`n_dimensions`](@ref) 
- [`atomic_symbol`](@ref)
- [`atomic_number`](@ref)
- [`element_symbol`](@ref)
- [`chemical_formula`](@ref)
- [`element`](@ref)
- [`visualize_ascii`](@ref)


## Testing Utilities

The `AtomsBaseTesting` package provides a few utility functions to test
downstream packages for having properly implemented the `AtomsBase` interface.
The tests are probably not complete, but they should be a good start ...
and as always PRs are welcome.

Two functions are provided, namely `make_test_system` to generate standard
`FlexibleSystem` test systems and `test_approx_eq` for testing approximate
equality between `AtomsBase` systems (of not necessarily the same type).
The basic idea of the functions is to use `make_test_system` to obtain a
test system, construct an identical system in a downstream library and then use
`test_approx_eq` to check they are actually equal.

For usage examples see the tests of [ExtXYZ](https://github.com/libAtoms/ExtXYZ.jl/blob/master/test/atomsbase.jl),
[AtomsIO](https://github.com/mfherbst/AtomsIO.jl/blob/master/test/xsf.jl),
[Chemfiles](https://github.com/chemfiles/Chemfiles.jl/blob/master/src/atomsbase.jl)
and [ASEconnect](https://github.com/mfherbst/ASEconvert.jl/blob/master/test/runtests.jl).
