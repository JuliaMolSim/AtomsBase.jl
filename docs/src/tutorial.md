# Tutorial

This page gives an overview of using `AtomsBase` in practice and introduces
the conventions followed across the `AtomsBase` ecosystem.
It serves as a reference for both users interested in doing something
with an [`AbstractSystem`](@ref) object as well as developers wishing to integrate
their code with `AtomsBase`.

For the examples we will mostly draw on the case of atomistic systems using the
[`FlexibleSystem`](@ref) data structure. See [Overview](@ref) for a more general
perspective of the `AtomsBase` interface. In practice we expect that the
[`Atom`](@ref) and [`FlexibleSystem`](@ref) data structure we focus on here
should provide good defaults for most purposes.

## High-level introduction
The main purpose of AtomsBase is to conveniently pass atomistic data between Julia packages.
For example the following snippet loads an extxyz file
using [AtomsIO](https://github.com/mfherbst/AtomsIO.jl)
and returns it as an `AtomsBase`-compatible system (in `data`):
```julia
using AtomsIO
data = load_system("Si.extxyz")
```
Next we use [ASEconvert](https://github.com/mfherbst/ASEconvert.jl) to convert
this system to python, such that we can make use of the
[atomistic simulation environment (ASE)](https://wiki.fysik.dtu.dk/ase/)
to form a `(2, 1, 1)` supercell, which is afterwards converted back
to Julia (by forming another `AtomsBase`-compatible system).
```julia
using ASEconvert
supercell = pyconvert(AbstractSystem, data * pytuple((2, 1, 1)))
```
Finally the `supercell` is passed to [DFTK](https://dftk.org),
where we attach pseudopotentials and run a PBE calculation:
```julia
using DFTK
cell_with_pseudos = attach_psp(supercell, Si="hgh/pbe/si-q4")
model = model_PBE(cell_with_pseudos)
basis = PlaneWaveBasis(model, Ecut=30, kgrid=(5, 5, 5)
self_consistent_field(basis).energy.total
```
For more high-level examples see also:
- The [DFTK documentation page on AtomsBase](https://docs.dftk.org/stable/examples/atomsbase/).
- The [AtomsIO documentation](https://mfherbst.github.io/AtomsIO.jl/stable)

## Atom interface and conventions
An `Atom` object can be constructed
just by passing an identifier (e.g. symbol like `:C`, atomic number like `6`) and a vector
of positions as
````@example atom
using Unitful, UnitfulAtomic, AtomsBase  # hide
atom = Atom(:C, [0, 1, 2.]u"bohr")
````
This automatically fills the atom with standard data such as the atomic mass.
See also the reference of the [`Atom`](@ref) function for more ways to construct an atom.

Such data can be accessed using the `AtomsBase` interface functions, such as:
````@example atom
atomic_mass(atom)
````
````@example atom
atomic_symbol(atom)
````
````@example atom
atomic_number(atom)
````
````@example atom
position(atom)
````
````@example atom
velocity(atom)
````
See [src/atom.jl](https://github.com/JuliaMolSim/AtomsBase.jl/blob/master/src/atom.jl)
and the respective API documentation for details.
Notice in particular that [`atomic_number`](@ref) will the element, i.e. the type
of an atom, whereas [`atomic_symbol`](@ref) may be more specific and may e.g. uniquely specify
a precise atom in the structure. An example could be a deuterium atom
````@example
using Unitful, UnitfulAtomic, AtomsBase  # hide
deuterium = Atom(1, atomic_symbol=:D, [0, 1, 2.]u"bohr")
````

An equivalent dict-like interface based on `keys`, `haskey`, `get` and `pairs`
is also available. For example
````@example atom
keys(atom)
````
````@example atom
atom[:atomic_symbol]
````
````@example atom
pairs(atom)
````
This interface seamlessly generalises to working with user-specific atomic properties
as will be discussed next.

### Optional atomic properties
Custom properties can be easily attached to an `Atom` by supplying arbitrary
keyword arguments upon construction. For example to attach a pseudopotential
for using the structure with [DFTK](https://dftk.org), construct the atom as
````@example atomprop
using Unitful, UnitfulAtomic, AtomsBase  # hide
atom = Atom(:C, [0, 1, 2.]u"bohr", pseudopotential="hgh/lda/c-q4")
````
which will make the pseudopotential identifier available as
````@example atomprop
atom[:pseudopotential]
````
Notice that such custom properties are fully integrated with the standard atomic properties,
e.g. automatically available from the `keys`, `haskey` and `pairs` functions, e.g.:
````@example atomprop
@show haskey(atom, :pseudopotential)
pairs(atom)
````
Updating an atomic property proceeds similarly. E.g.
````@example atomprop
using Unitful, UnitfulAtomic, AtomsBase  # hide
newatom = Atom(atom; atomic_mass=13u"u")
````
makes a new carbon atom with all properties identical to `atom` (including custom ones),
but setting the `atomic_mass` to 13 units.

To simplify interoperability some optional properties are reserved. For these:
- Throughout the `AtomsBase` ecosystem these property keys carry a well-defined meaning.
  I.e. if they are supported by a code, the code expects them to hold the data specified below.
- If a consuming code cannot make use of these properties, it should at least warn the user about it.
  For example if a library or simulation code does not support such a feature and drops the respective
  information it should `@warn` or (even better) interrupt execution with an error.

Property name       | Unit / Type        | Description
:------------------ | :----------------- | :---------------------
`:charge`           | `Charge`           | Net charge of the atom
`:covalent_radius`  | `Length`           | Covalent radius tabulated for the atom
`:vdw_radius`       | `Length`           | VdW radius tabulated for the atom
`:magnetic_moments` | `Union{Float64,Vector{Float64}}` | Initial magnetic moment
`:pseudopotential`  | `String`           | Pseudopotential or PAW keyword or `""` if Coulomb potential employed

A convenient way to iterate over all data stored in an atom offers the `pairs` function:
````@example atomprop
for (k, v) in pairs(atom)
    println("$k  =  $v")
end
````

## System interface and conventions
Once the atoms are constructed these can be assembled into a system.
For example to place a hydrogen molecule into a cubic box of `10Å` and periodic
boundary conditions, use:
````@example system
using Unitful, UnitfulAtomic, AtomsBase  # hide
box = [[10.0, 0.0, 0.0], [0.0, 10.0, 0.0], [0.0, 0.0, 10.0]]u"Å"
boundary_conditions = [Periodic(), Periodic(), Periodic()]
hydrogen = FlexibleSystem([Atom(:H, [0, 0, 1.]u"bohr"),
                           Atom(:H, [0, 0, 3.]u"bohr")],
                           box, boundary_conditions)
````
An update constructor for systems is supported as well (see [`AbstractSystem`](@ref)). For example
````@example system
AbstractSystem(hydrogen; bounding_box=[[5.0, 0.0, 0.0], [0.0, 5.0, 0.0], [0.0, 0.0, 5.0]]u"Å")
````
To update the atomic composition of the system, this function supports an `atoms` (or `particles`)
keyword argument to supply the new set of atoms to be contained in the system.

Note that in this example `FlexibleSystem( ... )` would have worked as well (since we are
updating a `FlexibleSystem`). However, using the `AbstractSystem` constructor to update the system
is more general as it allows for type-specific dispatching when updating other data structures
implementing the `AbstractSystem` interface.

Similar to the atoms, system objects similarly support a functional-style access to system properties
as well as a dict-style access:
````@example system
bounding_box(hydrogen)
````
````@example system
hydrogen[:boundary_conditions]
````
````@example system
pairs(hydrogen)
````
Moreover atomic properties of a specific atom or all atoms can be directly queried using
the indexing notation:
````@example system
hydrogen[1, :position]  # Position of first atom
````
````@example system
hydrogen[:, :position]  # All atomic symbols
````
Finally, supported keys of atomic properties can be directly queried at the system level
using [`atomkeys`](@ref) and [`hasatomkey`](@ref). Note that these functions only apply to atomic
properties which are supported by *all* atoms of a system. In other words if a custom atomic property is only
set in a few of the contained atoms, these functions will not consider it.
````@example system
atomkeys(hydrogen)
````

For constructing atomic systems the functions
[`atomic_system`](@ref), [`isolated_system`](@ref), [`periodic_system`](@ref)
are oftentimes more convenient as they provide specialisations
for some standard atomic system setups.
For example to setup a hydrogen system with periodic BCs, we can issue
````@example
using Unitful, UnitfulAtomic, AtomsBase  # hide
bounding_box = [[10.0, 0.0, 0.0], [0.0, 10.0, 0.0], [0.0, 0.0, 10.0]]u"Å"
hydrogen = periodic_system([:H => [0, 0, 1.]u"bohr",
                            :H => [0, 0, 3.]u"bohr"],
                           bounding_box)
````
To setup a silicon unit cell we can use fractional coordinates
(which is common for solid-state simulations):
````@example
using Unitful, UnitfulAtomic, AtomsBase  # hide
bounding_box = 10.26 / 2 * [[0, 0, 1], [1, 0, 1], [1, 1, 0]]u"bohr"
silicon = periodic_system([:Si =>  ones(3)/8,
                           :Si => -ones(3)/8],
                           bounding_box, fractional=true)
````
Alternatively we can also place an isolated H2 molecule in vacuum
(Infinite box and zero dirichlet BCs), which is the standard setup for
molecular simulations:
````@example
using Unitful, UnitfulAtomic, AtomsBase  # hide
hydrogen = isolated_system([:H => [0, 0, 1.]u"bohr",
                            :H => [0, 0, 3.]u"bohr"])
````

### Optional system properties
Similar to atoms, systems also support storing arbitrary data, for example
````@example sysprop
using Unitful, UnitfulAtomic, AtomsBase  # hide
system = isolated_system([:H => [0, 0, 1.]u"bohr", :H => [0, 0, 3.]u"bohr"]; extra_data=42)
````
Again these custom properties are fully integrated with `keys`, `haskey`, `pairs` and `get`.
````@example sysprop
@show keys(system)
````
Some property names are reserved and should be considered by all libraries
supporting `AtomsBase` if possible:

Property name   | Unit / Type        | Description
:-------------- | :----------------- | :---------------------
`:charge`       | `Charge`           | Total net system charge
`:multiplicity` | `Int` (unitless)   | Multiplicity of the ground state targeted in the calculation
