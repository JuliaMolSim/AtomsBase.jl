using AtomsBase
using StaticArrays
using Unitful

box = SVector(SVector(1u"m",0u"m",0u"m"),SVector(0u"m",1u"m",0u"m"),SVector(0u"m",0u"m",1u"m"))
# note: explicit typing is necessary here because the curren
bcs = SVector{3,BoundaryCondition}(Periodic(), Periodic(), Periodic())
positions = Vector([SVector(0.25u"m", 0.25u"m", 0.25u"m"), SVector(0.75u"m", 0.75u"m", 0.75u"m")])
elements = [ChemicalElement(:C), ChemicalElement(:C)]

atom1 = SimpleAtom(positions[1],elements[1])
atom2 = SimpleAtom(positions[2],elements[2])

aos = AoSSystem(box, bcs, [atom1, atom2])

soa = SoASystem(box, bcs, positions, elements)
