using AtomsBase
using StaticArrays
using Unitful

import PeriodicTable

periodic_table = PeriodicTable.elements

box = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]u"m"
bcs = [Periodic(), Periodic(), Periodic()]
positions = [0.25 0.25 0.25; 0.75 0.75 0.75]u"m"
elements = [periodic_table[:C], periodic_table[:C]]

atom1 = StaticAtom(SVector{3}(positions[1,:]),elements[1])
atom2 = StaticAtom(SVector{3}(positions[2,:]),elements[2])

aos = FlexibleSystem(box, bcs, [atom1, atom2])
soa = FastSystem(box, bcs, positions, elements)

# And now we can ask questions like...
soa .== aos
