


# --------------------------------------------- 
#  Simple wrapper for chemical element type 

import PeriodicTable
using Unitful

import Base: ==, convert, show, length

export ChemicalSpecies

"""
Encodes a chemical species by wrapping an integer that represents the atomic 
number, the number of protons, and additional unspecified information as a `UInt32`. 
"""
struct ChemicalSpecies
   atomic_number::Int16
   nprot::Int16
   info::UInt32
end

function Base.show(io::IO, element::ChemicalSpecies) 
    print(io, Symbol(element))
    if element.nprot != 0
        print(io, "($element.nprot)")
    end
end

Base.Broadcast.broadcastable(s::ChemicalSpecies) = Ref(s)

ChemicalSpecies(sym::Symbol) = ChemicalSpecies(_sym2z[sym]) 
ChemicalSpecies(z::Integer) = ChemicalSpecies(z, 0, 0) 
ChemicalSpecies(sym::ChemicalSpecies) = sym

==(a::ChemicalSpecies, sym::Symbol) = (Symbol(a) == sym)

# -------- fast access to the periodic table 

@assert length(PeriodicTable.elements) == maximum(el.number for el in PeriodicTable.elements)
@assert all(el.number == i for (i, el) in enumerate(PeriodicTable.elements))

const _chem_el_info = [ 
      (symbol = Symbol(PeriodicTable.elements[z].symbol), 
       atomic_mass = PeriodicTable.elements[z].atomic_mass, ) 
       for z in 1:length(PeriodicTable.elements)
      ]

const _sym2z = Dict{Symbol, UInt8}()
for z in 1:length(_chem_el_info)
   _sym2z[_chem_el_info[z].symbol] = z
end

# -------- accessor functions 
# TODO: some of these need to be adapted or throw errors when nprot ≠ 0. 

# UInt* is not readable
atomic_number(element::ChemicalSpecies) = element.atomic_number

atomic_symbol(element::ChemicalSpecies) = element 

Base.convert(::Type{Symbol}, element::ChemicalSpecies) = Symbol(element) 

Base.Symbol(element::ChemicalSpecies) = _chem_el_info[element.atomic_number].symbol

atomic_mass(element::ChemicalSpecies) = _chem_el_info[element.atomic_number].atomic_mass

rich_info(element::ChemicalSpecies) = PeriodicTable.elements[element.atomic_number]

element(element::ChemicalSpecies) = rich_info(element)


"""The element corresponding to a species/atom (or missing)."""
element(id::Union{Symbol,Integer}) = PeriodicTable.elements[id]  # Keep for better inlining

function element(name::AbstractString)
    try
        return PeriodicTable.elements[name]
    catch e
        if e isa KeyError
            throw(ArgumentError(
                "Unknown element name: $name. " *
                "Note that AtomsBase uses PeriodicTables to resolve element identifiers, " *
                "where strings are considered element names. To lookup an element by " *
                "element symbol use `Symbol`s instead, e.g. "*
                """`Atom(Symbol("Si"), zeros(3)u"Å")` or `Atom("silicon", zeros(3)u"Å")`."""
            ))
        else
            rethrow()
        end
    end
end



"""
    element_symbol(system, index)
    element_symbol(species)

Return the symbols corresponding to the elements of the atoms. Note that
this may be different than `atomic_symbol` for cases where `atomic_symbol`
is chosen to be more specific (i.e. designate a special atom).
"""
element_symbol(sys::AbstractSystem, index) = 
        element_symbol.(sys[index])

element_symbol(species) = 
        Symbol(element(atomic_number(species)).symbol)


"""
    atomic_symbol(sys::AbstractSystem, i)
    atomic_symbol(species)

Vector of atomic symbols in the system `sys` or the atomic symbol of a particular `species` /
the `i`th species in `sys`.

The intention is that [`atomic_number`](@ref) carries the meaning
of identifying the type of a `species` (e.g. the element for the case of an atom), whereas
[`atomic_symbol`](@ref) may return a more unique identifier. For example for a deuterium atom
this may be `:D` while `atomic_number` is still `1`.
"""
atomic_symbol(sys::AbstractSystem, index) = atomic_symbol.(species(sys, index))



"""
    atomic_number(sys::AbstractSystem, i)
    atomic_number(species)

Vector of atomic numbers in the system `sys` or the atomic number of a particular `species` /
the `i`th species in `sys`.

The intention is that [`atomic_number`](@ref) carries the meaning
of identifying the type of a `species` (e.g. the element for the case of an atom), whereas
[`atomic_symbol`](@ref) may return a more unique identifier. For example for a deuterium atom
this may be `:D` while `atomic_number` is still `1`.
"""
atomic_number(sys::AbstractSystem, index) = atomic_number.(species(sys, index))
