#
# A simple and flexible atom implementation
#
export Atom, atomic_system, periodic_system, isolated_system

# Valid types for atom identifiers
const AtomId = Union{Symbol,AbstractString,Integer}

struct Atom{D, L<:Unitful.Length, V<:Unitful.Velocity, M<:Unitful.Mass}
    position::SVector{D, L}
    velocity::SVector{D, V}
    atomic_symbol::Symbol
    atomic_number::Int
    atomic_mass::M
    data::Dict{Symbol, Any}  # Store arbitrary data about the atom.
end
velocity(atom::Atom)      = atom.velocity
position(atom::Atom)      = atom.position
atomic_mass(atom::Atom)   = atom.atomic_mass
atomic_symbol(atom::Atom) = atom.atomic_symbol
atomic_number(atom::Atom) = atom.atomic_number
element(atom::Atom)       = elements[atomic_symbol(atom)]
n_dimensions(atom::Atom{D}) where {D} = D
data(atom::Atom)          = atom.data

Base.hasproperty(at::Atom, x::Symbol) = hasfield(Atom, x) || haskey(at.data, x)
Base.getproperty(at::Atom, x::Symbol) = hasfield(Atom, x) ? getfield(at, x) : getindex(at.data, x)
function Base.propertynames(at::Atom, private::Bool=false)
    if private
        (fieldnames(Atom)..., keys(at.data)...)
    else
        (filter(!isequal(:data), fieldnames(Atom))..., keys(at.data)...)
    end
end

function Atom(identifier::AtomId,
              position::AbstractVector{L},
              velocity::AbstractVector{V}=zeros(length(position))u"bohr/s";
              atomic_symbol=Symbol(elements[identifier].symbol),
              atomic_number=elements[identifier].number,
              atomic_mass::M=elements[identifier].atomic_mass,
              kwargs...) where {L <: Unitful.Length, V <: Unitful.Velocity, M <: Unitful.Mass}
    Atom{length(position), L, V, M}(position, velocity, atomic_symbol,
                                    atomic_number, atomic_mass, Dict(kwargs...))
end

# Update constructor: Amend any atom by extra data.
function Atom(;atom, kwargs...)
    extra = atom isa Atom ? atom.data : (; )
    Atom(atomic_symbol(atom), position(atom), velocity(atom);
         atomic_symbol=atomic_symbol(atom),
         atomic_number=atomic_number(atom),
         atomic_mass=atomic_mass(atom),
         extra..., kwargs...)
end
Atom(atom::Atom; kwargs...) = Atom(; atom, kwargs...)

function Base.convert(::Type{Atom}, id_pos::Pair{<:AtomId,<:AbstractVector{<:Unitful.Length}})
    Atom(id_pos...)
end

function Base.show(io::IO, at::Atom{D, L}) where {D, L}
    pos  = ustrip.(at.position)
    print(io, "Atom($(at.atomic_symbol), [", join(pos, ", "), "]u\"$(unit(L))\")")
end

#
# Special high-level functions to construct atomic systems
#
atomic_system(atoms::AbstractVector{<:Atom}, box, bcs; kwargs...) = FlexibleSystem(atoms, box, bcs; kwargs...)
atomic_system(atoms::AbstractVector, box, bcs; kwargs...) = FlexibleSystem(convert.(Atom, atoms), box, bcs; kwargs...)


function isolated_system(atoms::AbstractVector{<:Atom}; kwargs...)
    # Use dummy box and boundary conditions
    D = n_dimensions(first(atoms))
    atomic_system(atoms, infinite_box(D), fill(DirichletZero(), D); kwargs...)
end
isolated_system(atoms::AbstractVector; kwargs...) = isolated_system(convert.(Atom, atoms); kwargs...)

function periodic_system(atoms::AbstractVector,
                         box::AbstractVector{<:AbstractVector};
                         fractional=false, kwargs...)
    boundary_conditions=fill(Periodic(), length(box))
    lattice = hcat(box...)
    !fractional && return atomic_system(atoms, box, boundary_conditions; kwargs...)

    parse_fractional(atom::Atom) = atom
    function parse_fractional(atom::Pair)::Atom
        id, pos_fractional = atom
        Atom(id, lattice * pos_fractional)
    end
    atomic_system(parse_fractional.(atoms), box, boundary_conditions; kwargs...)
end
