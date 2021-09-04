include("load_using_ase.jl")
include("supercell.jl")

iron  = load_using_ase("./Fe_afm.pwi")
super = make_supercell(iron, (2, 1, 1))

display(iron)
println()
println()
println()
display(super)
