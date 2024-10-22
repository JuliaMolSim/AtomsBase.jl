


# --------------------------------------------- 
#  Simple wrapper for chemical element type 

import PeriodicTable
using Unitful

import Base: ==, convert, show, length

export ChemicalSpecies

"""
Encodes a chemical species by wrapping an integer that represents the atomic 
number, the number of protons, and additional unspecified information as a `UInt32`. 

Constructors for standard chemical elements
```julia
ChemicalSpecies(Z::Integer)
ChemicalSpecies(sym::Symbol) 
# for example 
ChemicalSpecies(:C)
ChemicalSpecies(6)
```

Constructors for isotopes 
```julia 
# standard carbon = C-12
ChemicalSpecies(:C)
ChemicalSpecies(:C; n_neutrons = 6)

# three equivalent constructors for C-13
ChemicalSpecies(:C; n_neutrons = 7)
ChemicalSpecies(6; n_neutrons = 7)
ChemicalSpecies(:C13)
# deuterium
ChemicalSpecies(:D) 
```
"""
struct ChemicalSpecies
   atomic_number::Int16    # = Z = number of protons
   nneut::Int16            # number of neutrons
   info::UInt32
end


function Base.show(io::IO, element::ChemicalSpecies) 
    print(io, Symbol(element))
end

Base.Broadcast.broadcastable(s::ChemicalSpecies) = Ref(s)

# better to convert z -> symbol to catch special cases such as D; e.g. 
# Should ChemicalSpecies(z) == ChemicalSpecies(z,z,0)? For H this is false.
function ChemicalSpecies(z::Integer; kwargs...)
    ChemicalSpecies(_chem_el_info[z].symbol; kwargs...)
end

ChemicalSpecies(sym::ChemicalSpecies) = sym

==(a::ChemicalSpecies, sym::Symbol) = 
        ((a == ChemicalSpecies(sym)) && (Symbol(a) == sym))

# -------- fast access to the periodic table 

if length(PeriodicTable.elements) != maximum(el.number for el in PeriodicTable.elements)
    error("PeriodicTable.elements is not sorted by atomic number")
end

if !all(el.number == i for (i, el) in enumerate(PeriodicTable.elements))
    error("PeriodicTable.elements is not sorted by atomic number")
end

const _chem_el_info = [ 
      (symbol = Symbol(PeriodicTable.elements[z].symbol), 
       atomic_mass = PeriodicTable.elements[z].atomic_mass, ) 
       for z in 1:length(PeriodicTable.elements)
      ]

const _sym2z = Dict{Symbol, UInt8}()
for z in 1:length(_chem_el_info)
   _sym2z[_chem_el_info[z].symbol] = z
end

function _nneut_default(z::Integer) 
    nplusp = round(Int, ustrip(u"u", _chem_el_info[z].atomic_mass))
    return nplusp - z
end

function ChemicalSpecies(sym::Symbol; n_neutrons = -1, info = 0) 
    _islett(c::Char) = 'A' <= uppercase(c) <= 'Z'

    # TODO - special-casing deuterium to make tests pass 
    #        this should be handled better
    if sym == :D 
        return ChemicalSpecies(1, 1, info)
    end

    # number of neutrons is explicitly specified
    if n_neutrons != -1
        if !( all(_islett, String(sym)) && n_neutrons >= 0)
            throw(ArgumentError("Invalid arguments for ChemicalSpecies"))
        end
        Z = _sym2z[sym]
        return ChemicalSpecies(Z, n_neutrons, info)
    end

    # number of neutrons is encoded in the symbol
    str = String(sym)
    elem_str = str[1:findlast(_islett, str)]
    Z = _sym2z[Symbol(elem_str)]
    num_str = str[findlast(_islett, str)+1:end]
    if isempty(num_str)
        n_neutrons = _nneut_default(Z)
    else
        n_neutrons = parse(Int, num_str) - Z
    end
    return ChemicalSpecies(Z, n_neutrons, info)
end

function Base.Symbol(element::ChemicalSpecies) 
    str = "$(_chem_el_info[element.atomic_number].symbol)"
    if element.nneut != _nneut_default(element.atomic_number)
        str *= "$(element.atomic_number + element.nneut)"
    end

    # TODO: again special-casing deuterium; to be fixed. 
    if str == "H2"
        return :D
    end 

    return Symbol(str)
end
    


# -------- accessor functions 

# UInt* is not readable
atomic_number(element::ChemicalSpecies) = element.atomic_number

atomic_number(z::Integer) = z 

atomic_number(s::Symbol) = _sym2z[s]

atomic_symbol(element::ChemicalSpecies) = element 

Base.convert(::Type{Symbol}, element::ChemicalSpecies) = Symbol(element) 

mass(element::ChemicalSpecies) = _chem_el_info[element.atomic_number].atomic_mass

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
