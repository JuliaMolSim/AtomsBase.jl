# AtomsBase

*A Julian abstract interface for atomic structures.*

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaMolSim.github.io/AtomsBase.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaMolSim.github.io/AtomsBase.jl/dev)
[![Build Status](https://github.com/JuliaMolSim/AtomsBase.jl/workflows/CI/badge.svg)](https://github.com/JuliaMolSim/AtomsBase.jl/actions)
[![Coverage](https://codecov.io/gh/JuliaMolSim/AtomsBase.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaMolSim/AtomsBase.jl)

**AtomsBase is currently in the relatively early stages of development and we very much
want developer/user input! If you think anything about it should be 
added/removed/changed, _please_ [file an issue](https://github.com/JuliaMolSim/AtomsBase.jl/issues) or chime into the discussion on an
existing one! (Look particularly for issues with the [`question` label](https://github.com/JuliaMolSim/AtomsBase.jl/issues?q=is%3Aissue+is%3Aopen+label%3Aquestion))**

AtomsBase is an abstract interface for representation of atomic geometries in Julia. It aims to be a lightweight means of facilitating interoperability between various tools including...
* chemical simulation engines (e.g. density functional theory, molecular dynamics, etc.)
* file I/O with standard formats (.cif, .xyz, ...)
* numerical tools: sampling, integration schemes, etc.
* automatic differentiation and machine learning systems
* visualization (e.g. plot recipes)

Currently, the design philosophy is to be as lightweight as possible, with only
a small set of required function dispatches to make adopting the interface into
existing packages easy. We also provide a couple of
[standard flexible implementations of the interface](https://juliamolsim.github.io/AtomsBase.jl/stable/atomicsystems.html#atomic-systems)
that we envision to be broadly applicable.
If features beyond these are required we
encourage developers to open PRs or provide their own implementations.
For more on how to use the package, see [the documentation](https://juliamolsim.github.io/AtomsBase.jl/stable).

## Installation

AtomsBase can be installed using the Julia package manager.
From the Julia REPL, type `]` to enter the Pkg REPL mode and run

```
pkg> add AtomsBase
```

## Packages Using AtomsBase
The following (not all yet-registered) packages currently make use of this interface (please feel free to send a PR to add to this list!):
* [ASEPotential](https://github.com/jrdegreeff/ASEPotential.jl)
* [AtomIO](https://github.com/mfherbst/AtomIO.jl): I/O for atomic structures, also wraps some ASE functionality
* [Atomistic](https://github.com/cesmix-mit/Atomistic.jl/tree/263ec97b5f380f1b2ba593bf8feaf36e7f7cff9a): integrated workflow for MD simulations, part of [CESMIX](https://computing.mit.edu/cesmix/)
* [BFPIS](https://github.com/GDufenshuoo/BFPIS.jl)
* [ChemistryFeaturization](https://github.com/Chemellia/ChemistryFeaturization.jl): Interface for featurization of atomic structures for input into machine learning models, part of [Chemellia](https://chemellia.org)
* [DFTK](https://github.com/JuliaMolSim/DFTK.jl): density functional theory simulations
* [InteratomicPotentials](https://github.com/cesmix-mit/InteratomicPotentials.jl): implementations of a variety of interatomic potentials, also part of [CESMIX](https://computing.mit.edu/cesmix/)
* [Molly](https://github.com/JuliaMolSim/Molly.jl): molecular dynamics simulations
* [Xtals](https://github.com/SimonEnsemble/Xtals.jl): I/O and structure representation for crystals
