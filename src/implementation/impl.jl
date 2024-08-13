
module Implementation 

using Unitful, UnitfulAtomic, StaticArrays

import AtomsBase: AbstractSystem, SystemWithCell, 
         bounding_box, periodicity, get_cell, 
         n_dimensions, species, position, 
         velocity, element, 
         atomic_number, atomic_symbol, 
         mass, element, 
         show_atom, 
         AtomView, 
         atomkeys, hasatomkey

import AtomsBase: ChemicalSpecies, PCell, OpenSystemCell

export Atom, FlexibleSystem, FastSystem

include("atom.jl")
include("flexible_system.jl")
include("fast_system.jl")

end 