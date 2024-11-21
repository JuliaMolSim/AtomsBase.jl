#
# A simple and flexible atom implementation
#
export Atom, atomic_system, periodic_system, isolated_system

# Valid types for atom identifiers
const AtomId = Union{Symbol, AbstractString, Integer, ChemicalSpecies}



struct Atom{D, L<:Unitful.Length, V<:Unitful.Velocity, M<:Unitful.Mass}
    position::SVector{D, L}
    velocity::SVector{D, V}
    species::ChemicalSpecies
    mass::M
    data::Dict{Symbol, Any}  # Store arbitrary data about the atom.
end

velocity(atom::Atom) = atom.velocity
position(atom::Atom) = atom.position
mass(atom::Atom)     = atom.mass
species(atom::Atom)  = atom.species

n_dimensions(::Atom{D}) where {D} = D

atom_name(atom::Atom)     = atom_name(species(atom))
atomic_symbol(atom::Atom) = atomic_symbol(species(atom))
atomic_number(atom::Atom) = atomic_number(species(atom))
element(atom::Atom)       = element(species(atom))

Base.getindex(at::Atom, x::Symbol) = hasfield(Atom, x) ? getfield(at, x) : getindex(at.data, x)
Base.haskey(at::Atom,   x::Symbol) = hasfield(Atom, x) || haskey(at.data, x)
function Base.get(at::Atom, x::Symbol, default)
    hasfield(Atom, x) ? getfield(at, x) : get(at.data, x, default)
end
function Base.keys(at::Atom)
    (:position, :velocity, :species, :mass, keys(at.data)...)
end
Base.pairs(at::Atom) = (k => at[k] for k in keys(at))

"""
    Atom(identifier::AtomId, position::AbstractVector; kwargs...)
    Atom(identifier::AtomId, position::AbstractVector, velocity::AbstractVector; kwargs...)
    Atom(; atomic_number, position, velocity=zeros(D)u"bohr/s", kwargs...)

Construct an atomic located at the cartesian coordinates `position` with (optionally)
the given cartesian `velocity`. Note that `AtomId = Union{Symbol,AbstractString,Integer,ChemicalSymbol}`.

Supported `kwargs` include `species`, `mass`, as well as user-specific custom properties.
"""
function Atom(identifier::AtomId,
              position::AbstractVector{L},
              velocity::AbstractVector{V}=_default_velocity(position);
              species=ChemicalSpecies(identifier),
              mass::M=mass(species),
              kwargs...) where {L <: Unitful.Length, V <: Unitful.Velocity, M <: Unitful.Mass}
    Atom{length(position), L, V, M}(position, velocity, species,
                                    mass, Dict(kwargs...))
end


function _default_velocity(position::AbstractVector{L}) where {L <: Unitful.Length} 
    TFL = eltype(ustrip(position[1]))
    uL = unit(position[1])
    if uL == u"Å"
        return zeros(TFL, length(position))u"Å/fs"
    elseif uL == u"nm"
        return zeros(TFL, length(position))u"nm/ps"
    elseif uL == u"bohr" 
        return zeros(TFL, length(position))u"nm/s"
    elseif uL == u"m" 
        return zeros(TFL, length(position))u"m/s"
    end 
    @warn("Cannot infer default velocity for position with unit $(unit(position[1]))")
    return zeros(TFL, length(position)) * (uL / u"s")
end 


function Atom(id::AtomId, position::AbstractVector, velocity::Missing; kwargs...)
    Atom(id, position, zeros(length(position))u"bohr/s"; kwargs...)
end

function Atom(; velocity=zeros(length(position))u"bohr/s", kwargs...)
    ididx = findlast(x -> x ∈ (:species, :atomic_number, :atomic_symbol), 
                    keys(kwargs))
    id = kwargs[ididx] 
    position = kwargs[:position]
    kwargs = filter(x -> x[1] ∉ (:species, :position, :velocity, :atomic_number, 
                                :atomic_symbol), kwargs)
    Atom(id, position, velocity; kwargs...)
end

"""
    Atom(atom::Atom; kwargs...)

Update constructor. Construct a new `Atom`, by amending the data contained
in the passed `atom` object.
Supported `kwargs` include `species`, `mass`, as well as user-specific custom properties.

# Examples
Construct a standard hydrogen atom located at the origin
```julia-repl
julia> hydrogen = Atom(:H, zeros(3)u"Å")
```
and now amend its charge and atomic mass
```julia-repl
julia> Atom(atom; mass=1.0u"u", charge=-1.0u"e_au")
```
"""
Atom(atom::Atom; kwargs...) = Atom(; pairs(atom)..., kwargs...)

function Base.convert(::Type{Atom}, id_pos::Pair{<:AtomId,<:AbstractVector{<:Unitful.Length}})
    Atom(id_pos...)
end

Base.show(io::IO, at::Atom) = show_atom(io, at)
Base.show(io::IO, mime::MIME"text/plain", at::Atom) = show_atom(io, mime, at)


