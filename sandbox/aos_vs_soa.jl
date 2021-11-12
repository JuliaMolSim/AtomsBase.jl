using AtomsBase
using StaticArrays
using Unitful
using PeriodicTable

box = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]u"m"
bcs = [Periodic(), Periodic(), Periodic()]
positions = [0.25 0.25 0.25; 0.75 0.75 0.75]u"m"
elems = [elements[:C], elements[:C]]

atom1 = StaticAtom(SVector{3}(positions[1,:]),elems[1])
atom2 = StaticAtom(SVector{3}(positions[2,:]),elems[2])

aos = FlexibleSystem(box, bcs, [atom1, atom2])
soa = FastSystem(box, bcs, positions, elems)

# And now we can ask questions like...
soa .== aos
