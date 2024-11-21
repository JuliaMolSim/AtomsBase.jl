```@meta
CurrentModule = AtomsBase
```

# API reference

## Index

```@index
Pages = ["apireference.md"]
```

## Types 

```@docs
AbstractSystem
IsolatedCell
PeriodicCell 
AtomView
ChemicalSpecies 
```

## System properties

```@docs
cell_vectors
set_cell_vectors!
periodicity
set_periodicity!
cell 
set_cell! 
n_dimensions
atomkeys
hasatomkey
chemical_formula
visualize_ascii
```

## Species / atom properties

```@docs
position
set_position!
mass
set_mass!
species
set_species!
velocity
set_velocity!
atomic_number
atomic_symbol
atom_name
element_symbol
element 
```


## Prototype Implementation

```@docs
Atom
FlexibleSystem
FastSystem
atomic_system
isolated_system
periodic_system 
```
