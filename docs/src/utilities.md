
```@meta
CurrentModule = AtomsBase
```

# Utilities

This page documents some utilities that AtomsBase provides in addition to the interface. This documentation is preliminary. PRs to improve it are welcome. 

## Cell Types 

As of AtomsBase 0.4 we recommend that implementations of the interface specify a computational cell type. To simplify this, AtomsBase provides two prototype implementations: 

- [`PCell`](@ref) : implements the standard parallepiped shaped cell defined through three cell vectors and periodicity (true or false) along each cell vector.
- [`OpenSystemCell`](@ref) : implements a computational cell that is open (infinite) in all directions, i.e. the entire space.


## Chemical Species 

The function [`AtomsBase.species(sys, i)`](@ref) return the particle species of a particle (or multiple particles). AtomsBase does not enforce any specific type to be returned. However, it is recommended that systems describing atomic structures use - whenever possible - the `ChemicalSpecies` type that is implemented as part of `AtomsBase`.

- [`ChemicalSpecies`](@ref) : a prototype implementation and recommended default for the species of an atom.

## Convenience utilities

AtomsBase provides a number of convenience utilities that should work for any system that implements the AtomsBase interface. If they not work as expected this is likely a bug and should be reported as an issue. 

- `atomic_mass = mass` : deprecated 
- [`n_dimensions`](@ref) 
- [`atomic_symbol`](@ref)
- [`atomic_number`](@ref)
- [`element_symbol`](@ref)
- [`chemical_formula`](@ref)
- [`element`](@ref)
- [`visualize_ascii`](@ref)
