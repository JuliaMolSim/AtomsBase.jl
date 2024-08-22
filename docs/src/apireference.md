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
SystemWithCell
OpenSystemCell
PCell 
AtomView
ChemicalSpecies 
```

## System properties

```@docs
bounding_box
set_bounding_box!
periodicity
set_periodicity!
get_cell 
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
