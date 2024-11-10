


# --------------------------------------------- 
#  Simple wrapper for chemical element type 

import PeriodicTable
using Unitful

import Base: ==, convert, show, length

export ChemicalSpecies

# masses are saved in a different file to not clutter this file
include("isotope_masses.jl")

"""
Encodes a chemical species by wrapping an integer that represents the atomic 
number, the number of protons, and additional name as max 4 characters.

The name variable can be used as atom name in PDB format or
some other way to mark same kind of atoms from one another.

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

Constructors for names
```julia
ChemicalSpecies(:C; atomic_name=:MyC)
ChemicalSpecies(:C13; atomic_name=:MyC)
```

Comparisons with different isotopes and names
```julia
# true
ChemicalSpecies(:C13) == ChemicalSpecies(:C)

# false
ChemicalSpecies(:C12) == ChemicalSpecies(:C13)

# true
ChemicalSpecies(:C; atomic_name=:MyC) == ChemicalSpecies(:C)

# true
ChemicalSpecies(:C12; atomic_name=:MyC) == ChemicalSpecies(:C12)

# false
ChemicalSpecies(:C; atomic_name=:MyC) == ChemicalSpecies(:C12)

# true
ChemicalSpecies(:C12; atomic_name=:MyC) == ChemicalSpecies(:C)

# true
ChemicalSpecies(:C; atomic_name=:MyC) == ChemicalSpecies(:C12; atomic_name=:MyC)
```

"""
struct ChemicalSpecies
   atomic_number::Int16    # = Z = number of protons
   n_neutrons::Int16            # number of neutrons
   name::UInt32
end


function Base.show(io::IO, element::ChemicalSpecies) 
    print(io, Symbol(element))
end

Base.Broadcast.broadcastable(s::ChemicalSpecies) = Ref(s)

function ChemicalSpecies(asymbol::Symbol; atomic_name::Symbol=Symbol(""), n_neutrons::Int=-1)
    str_symbol = String(asymbol)
    tmp = 0
    if length(str_symbol) > 1 && isnumeric(str_symbol[end])
        # we exclude the case where n_neutrons > 99
        if  length(str_symbol) > 2 && isnumeric(str_symbol[end])
            tmp = parse(Int, str_symbol[end-1:end])
            str_symbol = str_symbol[1:end-2]
        else
            tmp = parse(Int, str_symbol[end])
            str_symbol = str_symbol[1:end-1]
        end
    end
    asymbol = Symbol(str_symbol)
    z = haskey(_sym2z, asymbol) ? _sym2z[asymbol] : 0
    n_neutrons = tmp == 0 ? n_neutrons : tmp - z
    if asymbol in [:D, :T]
        z = 1
        n_neutrons = asymbol == :D ? 1 : 2
    end
    return ChemicalSpecies(Int(z); atomic_name=atomic_name, n_neutrons=n_neutrons)
end 

function ChemicalSpecies(z::Integer; atomic_name::Symbol=Symbol(""), n_neutrons::Int=-1)
    atom_name = String(atomic_name)
    if length(atom_name) > 4
        throw(ArgumentError("atomic_name has to be max 4 characters"))
    end
    if length(atom_name) == 0
        return ChemicalSpecies(z, n_neutrons, zero(UInt32),)
    end
    tmp = repeat(' ', 4 - length(atom_name)) * atom_name
    tmp2 = SVector{4, UInt8}( tmp[1], tmp[2], tmp[3], tmp[4] )
    name = reinterpret(reshape, UInt32, tmp2)[1]
    return ChemicalSpecies(z, n_neutrons, name)
end

ChemicalSpecies(sym::ChemicalSpecies) = sym

==(a::ChemicalSpecies, sym::Symbol) = 
        ((a == ChemicalSpecies(sym)) && (Symbol(a) == sym))


function ==(cs1::ChemicalSpecies, cs2::ChemicalSpecies)
    if cs1.atomic_number != cs2.atomic_number
        return false
    elseif (cs1.n_neutrons >= 0 && cs2.n_neutrons >= 0) && cs1.n_neutrons != cs2.n_neutrons
        return false
    elseif (cs1.name != 0 && cs2.name != 0) && cs1.name != cs2.name
        return false
    elseif (cs1.n_neutrons < 0 && cs1.name == 0) || (cs2.n_neutrons < 0 && cs2.name == 0)
        return true
    elseif cs1.n_neutrons != cs2.n_neutrons && cs1.name != cs2.name
        return false
    else
        return true
    end
end

# -------- fast access to the periodic table 

const _sym2z = Dict{Symbol, UInt8}(
    Symbol(el.symbol) => el.number for el in PeriodicTable.elements
)

const _z2sym = Dict{UInt8, Symbol}(
    el.number => Symbol(el.symbol) for el in PeriodicTable.elements
)

const _z2mass = Dict{UInt8, typeof(PeriodicTable.elements[1].atomic_mass)}(
    el.number => el.atomic_mass for el in PeriodicTable.elements
)


function Base.Symbol(element::ChemicalSpecies)
    tmp = element.atomic_number == 0 ? :X : _z2sym[element.atomic_number]
    if element.n_neutrons < 0
        return tmp
    end
    if element.atomic_number == 1 && element.n_neutrons == 1
        return :D
    end
    if element.atomic_number == 1 && element.n_neutrons == 2
        return :T
    end
    n = element.atomic_number + element.n_neutrons
    return Symbol("$tmp$n")
end


# -------- accessor functions 

# UInt* is not readable
atomic_number(element::ChemicalSpecies) = element.atomic_number

atomic_number(z::Integer) = z 

atomic_number(s::Symbol) = _sym2z[s]

atomic_symbol(element::ChemicalSpecies) = element 

Base.convert(::Type{Symbol}, element::ChemicalSpecies) = Symbol(element) 

function mass(element::ChemicalSpecies)
    if element.n_neutrons < 0
        if haskey(_z2mass, element.atomic_number)
            return _z2mass[element.atomic_number]
        else
            return 0.0u"u"
        end
    end
    akey = (element.atomic_number, element.n_neutrons)
    if haskey(_isotope_masses, akey)
        return _isotope_masses[akey] * u"u"
    end
    return missing
end


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




"""
    atomic_name(species)
    atomic_name(sys::AbstractSystem, i)

Return atomic name (`Symbol`) for `species` or vector of names for `sys`.

Defaults to [`atomic_symbol`](@ref), if `name` field is zero or not defined.
"""
function atomic_name(cs::ChemicalSpecies)
   if cs.name == 0
       return atomic_symbol(cs)
   else
       # filter first empty space characters
       as_characters = Char.( reinterpret(SVector{4, UInt8}, [cs.name])[1] )
       tmp = String( filter( x -> ! isspace(x), as_characters ) )
       return Symbol( tmp )
   end
end

atomic_name(at) = atomic_symbol(at)

atomic_name(sys::AbstractSystem, index) = atomic_name.(species(sys, index))