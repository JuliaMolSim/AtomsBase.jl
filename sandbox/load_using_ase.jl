using PyCall
using Unitful
using UnitfulAtomic
using AtomsBase

# Convert ase Atoms to 3D SimpleAtomicSystem ... could do this via the interface lazily later
function ase_to_simple(atoms)
    cell = [vec * 1u"Å" for vec in atoms.cell]  # Check this picks up the vectors in the right order
    boundary_conditions = [(isperiodic ? Periodic() : DirichletZero()) for isperiodic in atoms.pbc]
    simple_atoms = [SimpleAtom{3}(atom.position * 1u"Å", Symbol(atom.symbol))
                    for atom in atoms]
    SimpleAtomicSystem{3}(cell, boundary_conditions, simple_atoms)
end

load_using_ase(filename; kwargs...) = ase_to_simple(pyimport("ase.io").read(filename; kwargs...))

# Field for fractional
# Field for pseudos
# Field for magnetic moments
