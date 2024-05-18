# --------------------------------------------- 
#  Simple wrapper for chemical element type 

import PeriodicTable
using Unitful


"""
Encodes a chemical element by wrapping an integer that represents the atomic 
number. 
"""
struct ChemicalElement
    atomic_number::UInt8
end

Base.show(io::IO, element::ChemicalElement) = 
      print(io, atomic_symbol(element))


# -------- fast access to the periodic table 

@assert length(PeriodicTable.elements) == maximum(el.number for el in PeriodicTable.elements)
@assert all(el.number == i for (i, el) in enumerate(PeriodicTable.elements))

const _chem_el_info = [ 
      (symbol = Symbol(PeriodicTable.elements[z].symbol), 
       atomic_mass = PeriodicTable.elements[z].atomic_mass, ) 
       for z in 1:length(PeriodicTable.elements)
      ]


# -------- accessor functions 

atomic_number(element::ChemicalElement) = element.atomic_number

atomic_symbol(element::ChemicalElement) = _chem_el_info[element.atomic_number].symbol

atomic_mass(element::ChemicalElement) = _chem_el_info[element.atomic_number].atomic_mass

rich_info(element::ChemicalElement) = PeriodicTable.elements[element.atomic_number]
