# AtomsBase

*A Julian abstract interface for atomic structures.*

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaMolSim.github.io/AtomsBase.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaMolSim.github.io/AtomsBase.jl/dev)
[![Build Status](https://github.com/JuliaMolSim/AtomsBase.jl/workflows/CI/badge.svg)](https://github.com/JuliaMolSim/AtomsBase.jl/actions)
[![Coverage](https://codecov.io/gh/JuliaMolSim/AtomsBase.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaMolSim/AtomsBase.jl)

AtomsBase is an abstract interface for representation of atomic geometries in
Julia. It aims to be a lightweight means of facilitating interoperability
between various tools including, e.g., 

* Simulation engines, e.g. molecular dynamics, geometry optimization, etc 
* Computing chemical or mechanical properties, e.g., via DFT, or interatomic potentials,
* Integration with third party-libraries
* I/O with standard file formats (.cif, .xyz, ...)
* automatic differentiation and machine learning systems
* numerical tools: sampling, integration schemes, etc.
* visualization (e.g. plot recipes)

While AtomsBase focusses on representation of atomic systems, the sister package [`AtomsCalculators`](https://github.com/JuliaMolSim/AtomsCalculators.jl) provides a general interface to compute properties of such systems. 

Currently, the design philosophy is to be as lightweight as possible with a small set
of required function dispatches to make adopting the interface easy.
We also provide 
[prototype implementations](https://juliamolsim.github.io/AtomsBase.jl/stable/atomicsystems/#atomic-systems)
that we envision to be broadly applicable.
If features beyond these are required we encourage developers to open PRs or provide their own implementations.
For more on how to use the package,
see [the documentation](https://juliamolsim.github.io/AtomsBase.jl/stable).

## Packages using AtomsBase

The following (not all yet-registered) packages currently make use of AtomsBase:
* [ACEpotentials](https://github.com/ACEsuit/ACEpotentials.jl)
* [ASEPotential](https://github.com/jrdegreeff/ASEPotential.jl)
* [ASEconvert](https://github.com/mfherbst/ASEconvert.jl) : integration with the Atomistic Simulation Environment
* [AtomIO](https://github.com/mfherbst/AtomIO.jl): I/O for atomic structures, also wraps some ASE functionality
* [Atomistic](https://github.com/cesmix-mit/Atomistic.jl/tree/263ec97b5f380f1b2ba593bf8feaf36e7f7cff9a): integrated workflow for MD simulations, part of [CESMIX](https://computing.mit.edu/cesmix/)
* [AutoBZCore.jl](https://github.com/lxvm/AutoBZCore.jl/): Brillouin-zone integration
* [BFPIS](https://github.com/GDufenshuoo/BFPIS.jl)
* [ChemistryFeaturization](https://github.com/Chemellia/ChemistryFeaturization.jl): Interface for featurization of atomic structures for input into machine learning models, part of [Chemellia](https://chemellia.org)
* [DFTK](https://github.com/JuliaMolSim/DFTK.jl): density functional theory simulations
* [EmpiricalPotentials](https://github.com/JuliaMolSim/EmpiricalPotentials.jl)
* [ExtXYZ](https://github.com/libAtoms/ExtXYZ.jl): Parser for extended XYZ files
* [InteratomicPotentials](https://github.com/cesmix-mit/InteratomicPotentials.jl): implementations of a variety of interatomic potentials, also part of [CESMIX](https://computing.mit.edu/cesmix/)
* [Molly](https://github.com/JuliaMolSim/Molly.jl): molecular dynamics simulations
* [Xtals](https://github.com/SimonEnsemble/Xtals.jl): I/O and structure representation for crystals
