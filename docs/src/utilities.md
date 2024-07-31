
```@meta
CurrentModule = AtomsBase
```

# Utilities


## Cell Types 

- `PCell` 
- `OpenCell`


## Chemical Species 

- `ChemicalSpecies` 
- `chemical_formula` 

## Misc 

### Derived convenience functions 

- `atomic_mass = mass` : deprecated 
- [`n_dimensions`](@ref) 
- [`atomic_symbol`](@ref)
- [`atomic_number`](@ref)


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
