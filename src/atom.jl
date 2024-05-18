#
# A simple and flexible atom implementation
#
export Atom, atomic_system, periodic_system, isolated_system


# Valid types for user-oriented atom identifiers
const AtomId = Union{Symbol, AbstractString, Integer, ChemicalElement}



# --------------------------------------------- 
#  Implementation of a maximally flexible Atom type 


struct Atom{D, L<:Unitful.Length, V<:Unitful.Velocity, M<:Unitful.Mass}
    position::SVector{D, L}
    velocity::SVector{D, V}
    element::ChemicalElement
    atomic_mass::M
    data::Dict{Symbol, Any}  # Store arbitrary data about the atom.
end

velocity(atom::Atom)      = atom.velocity
position(atom::Atom)      = atom.position
atomic_mass(atom::Atom)   = atom.atomic_mass
atomic_symbol(atom::Atom) = atomic_symbol(atom.element)
atomic_number(atom::Atom) = atomic_number(atom.element)
element(atom::Atom)       = element(atomic_number(atom))
n_dimensions(::Atom{D}) where {D} = D

Base.getindex(at::Atom, x::Symbol) = hasfield(Atom, x) ? getfield(at, x) : getindex(at.data, x)
Base.haskey(at::Atom,   x::Symbol) = hasfield(Atom, x) || haskey(at.data, x)
function Base.get(at::Atom, x::Symbol, default)
    hasfield(Atom, x) ? getfield(at, x) : get(at.data, x, default)
end
function Base.keys(at::Atom)
    (:position, :velocity, :atomic_symbol, :atomic_number, :atomic_mass, keys(at.data)...)
end
Base.pairs(at::Atom) = (k => at[k] for k in keys(at))

"""
    Atom(identifier::AtomId, position::AbstractVector; kwargs...)
    Atom(identifier::AtomId, position::AbstractVector, velocity::AbstractVector; kwargs...)
    Atom(; atomic_number, position, velocity=zeros(D)u"bohr/s", kwargs...)

Construct an atomic located at the cartesian coordinates `position` with (optionally)
the given cartesian `velocity`. Note that `AtomId = Union{Symbol,AbstractString,Integer}`.

Supported `kwargs` include `atomic_symbol`, `atomic_number`, `atomic_mass`, `charge`,
`multiplicity` as well as user-specific custom properties.
"""
function Atom(identifier::AtomId,
              position::AbstractVector{L},
              velocity::AbstractVector{V}=zeros(length(position))u"bohr/s";
              chemical_element = ChemicalElement(identifier),
              atomic_mass::M = element(chemical_element).atomic_mass,
              kwargs...) where {L <: Unitful.Length, V <: Unitful.Velocity, M <: Unitful.Mass}
    Atom{length(position), L, V, M}(position, velocity, atomic_symbol,
                                    atomic_number, atomic_mass, Dict(kwargs...))
end
function Atom(id::AtomId, position::AbstractVector, velocity::Missing; kwargs...)
    Atom(id, position, zeros(length(position))u"bohr/s"; kwargs...)
end
function Atom(; atomic_symbol, position, velocity=zeros(length(position))u"bohr/s", kwargs...)
    Atom(atomic_symbol, position, velocity; atomic_symbol, kwargs...)
end

"""
    Atom(atom::Atom; kwargs...)

Update constructor. Construct a new `Atom`, by amending the data contained
in the passed `atom` object.
Supported `kwargs` include `atomic_symbol`, `atomic_number`, `atomic_mass`, `charge`,
`multiplicity` as well as user-specific custom properties.

# Examples
Construct a standard hydrogen atom located at the origin
```julia-repl
julia> hydrogen = Atom(:H, zeros(3)u"Å")
```
and now amend its charge and atomic mass
```julia-repl
julia> Atom(atom; atomic_mass=1.0u"u", charge=-1.0u"e_au")
```
"""
Atom(atom::Atom; kwargs...) = Atom(; pairs(atom)..., kwargs...)

function Base.convert(::Type{Atom}, id_pos::Pair{<:AtomId,<:AbstractVector{<:Unitful.Length}})
    Atom(id_pos...)
end

Base.show(io::IO, at::Atom) = show_atom(io, at)
Base.show(io::IO, mime::MIME"text/plain", at::Atom) = show_atom(io, mime, at)




# --------------------------------------------- 
#  Implementation of a FastAtom type which is isbits 
#  and provides equivalent functionality to `FastSystem`

"""
`FastAtom` : atom type compatible with `FastSystem`, i.e. providing only 
    atom id (chemical element), position and mass. It is isbits and hence 
    can be used with `FlexibleSystem` and achieve similar performance 
    as `FastSystem`.

### Constructors: 
```
Atom(identifier::AtomId, position::AbstractVector; atomic_mass)
Atom(; identifier, position, atomic_mass)
```
If `mass` is not provided then it the default provided by `PeriodicTable.jl` 
is assigned. 
"""
struct FastAtom{D, L<:Unitful.Length, M<:Unitful.Mass}
    element::ChemicalElement
    position::SVector{D, L} 
    atomic_mass::M
end

velocity(atom::FastAtom)      = missing 
position(atom::FastAtom)      = atom.position
atomic_mass(atom::FastAtom)   = atom.atomic_mass
atomic_symbol(atom::FastAtom) = atomic_symbol(atom.element)
atomic_number(atom::FastAtom) = atomic_number(atom.element)
element(atom::FastAtom)       = atom.element 
n_dimensions(::FastAtom{D}) where {D} = D

Base.getindex(at::FastAtom, x::Symbol) =   
        hasfield(FastAtom, x) ? getfield(at, x) : missing 

Base.haskey(at::FastAtom,   x::Symbol) = 
        hasfield(FastAtom, x)

Base.get(at::FastAtom, x::Symbol, default) = 
        hasfield(FastAtom, x) ? getfield(at, x) : default 

Base.keys(at::FastAtom) = 
        (:position, :element, :atomic_mass,)

Base.pairs(at::FastAtom) = 
        (k => at[k] for k in keys(at))


function FastAtom(identifier::AtomId, position::AbstractVector{L};
              chemical_element = ChemicalElement(identifier),
              atomic_mass::M   = atomic_mass(chemical_element),
            ) where {L <: Unitful.Length, M <: Unitful.Mass}
    D = length(position)            
    return FastAtom(chemical_element, SVector{D}(position), atomic_mass)
end

function FastAtom(; atomic_symbol, position, kwargs...)
    return FastAtom(atomic_symbol, position; kwargs...)
end



# --------------------------------------------- 
# Special high-level functions to construct atomic systems
#

"""
    atomic_system(atoms::AbstractVector, bounding_box, boundary_conditions; kwargs...)

Construct a [`FlexibleSystem`](@ref) using the passed `atoms` and boundary box and conditions.
Extra `kwargs` are stored as custom system properties.

# Examples
Construct a hydrogen molecule in a box, which is periodic only in the first two dimensions
```julia-repl
julia> bounding_box = [[10.0, 0.0, 0.0], [0.0, 10.0, 0.0], [0.0, 0.0, 10.0]]u"Å"
julia> boundary_conditions = [Periodic(), Periodic(), DirichletZero()]
julia> hydrogen = atomic_system([:H => [0, 0, 1.]u"bohr",
                                 :H => [0, 0, 3.]u"bohr"],
                                  bounding_box, boundary_conditions)
```
"""
atomic_system(atoms::AbstractVector{<:Atom}, box, bcs; kwargs...) = FlexibleSystem(atoms, box, bcs; kwargs...)
atomic_system(atoms::AbstractVector, box, bcs; kwargs...) = FlexibleSystem(convert.(Atom, atoms), box, bcs; kwargs...)


"""
    isolated_system(atoms::AbstractVector; kwargs...)

Construct a [`FlexibleSystem`](@ref) by placing the passed `atoms` into an infinite vacuum
(standard setup for modelling molecular systems). Extra `kwargs` are stored as custom system properties.

# Examples
Construct a hydrogen molecule
```julia-repl
julia> hydrogen = isolated_system([:H => [0, 0, 1.]u"bohr", :H => [0, 0, 3.]u"bohr"])
```
"""
function isolated_system(atoms::AbstractVector{<:Atom}; kwargs...)
    # Use dummy box and boundary conditions
    D = n_dimensions(first(atoms))
    atomic_system(atoms, infinite_box(D), fill(DirichletZero(), D); kwargs...)
end
isolated_system(atoms::AbstractVector; kwargs...) = isolated_system(convert.(Atom, atoms); kwargs...)


"""
    periodic_system(atoms::AbstractVector, bounding_box; fractional=false, kwargs...)

Construct a [`FlexibleSystem`](@ref) with all boundaries of the `bounding_box` periodic
(standard setup for modelling solid-state systems). If `fractional` is true, atom coordinates
are given in fractional (and not in Cartesian) coordinates.
Extra `kwargs` are stored as custom system properties.

# Examples
Setup a hydrogen molecule inside periodic BCs:
```julia-repl
julia> bounding_box = [[10.0, 0.0, 0.0], [0.0, 10.0, 0.0], [0.0, 0.0, 10.0]]u"Å"
julia> hydrogen = periodic_system([:H => [0, 0, 1.]u"bohr",
                                   :H => [0, 0, 3.]u"bohr"],
                                  bounding_box)
```

Setup a silicon unit cell using fractional positions
```julia-repl
julia> bounding_box = 10.26 / 2 * [[0, 0, 1], [1, 0, 1], [1, 1, 0]]u"bohr"
julia> silicon = periodic_system([:Si =>  ones(3)/8,
                                  :Si => -ones(3)/8],
                                 bounding_box, fractional=true)
```
"""
function periodic_system(atoms::AbstractVector,
                         box::AbstractVector{<:AbstractVector};
                         fractional=false, kwargs...)
    boundary_conditions = fill(Periodic(), length(box))
    lattice = hcat(box...)
    !fractional && return atomic_system(atoms, box, boundary_conditions; kwargs...)

    parse_fractional(atom::Atom) = atom
    function parse_fractional(atom::Pair)::Atom
        id, pos_fractional = atom
        Atom(id, lattice * pos_fractional)
    end
    atomic_system(parse_fractional.(atoms), box, boundary_conditions; kwargs...)
end
