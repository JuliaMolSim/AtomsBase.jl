# [Atomic systems](@id atomic-systems)
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

## Struct of Arrays / FastSystem
The file [src/fast_system.jl](https://github.com/JuliaMolSim/AtomsBase.jl/blob/master/src/fast_system.jl) contains an implementation of
AtomsBase based on the struct-of-arrays approach. All species data is stored
as plain arrays, but for convenience indexing of individual atoms is supported
by a light-weight `AtomView`. See the implementation files
as well as the tests for how these can be used.

## Atoms and FlexibleSystem
A flexible implementation of the interface is provided by the
`FlexibleSystem` and the `Atom` structs
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
See [src/atom.jl](https://github.com/JuliaMolSim/AtomsBase.jl/blob/master/src/atom.jl) for details.

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
An update constructor is supported as well (see [src/flexible_system.jl](https://github.com/JuliaMolSim/AtomsBase.jl/blob/master/src/flexible_system.jl)).

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

