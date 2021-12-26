#
# A simple and flexible atom implementation
#
export Atom, atomic_system, periodic_system, isolated_system

struct Atom{D, L<:Unitful.Length, M<:Unitful.Mass}
    position::SVector{D, L}
    atomic_symbol::Symbol
    atomic_number::Int
    atomic_mass::M
    data::Dict{Symbol, Any}  # Store arbitrary data about the atom.
end
velocity(::Atom)          = missing
position(atom::Atom)      = atom.position
atomic_mass(atom::Atom)   = atom.atomic_mass
atomic_symbol(atom::Atom) = atom.atomic_symbol
atomic_number(atom::Atom) = atom.atomic_number
element(atom::Atom)       = elements[atomic_symbol(atom)]
n_dimensions(atom::Atom{D}) where {D} = D

Base.hasproperty(at::Atom, x::Symbol) = hasfield(Atom, x) || haskey(at.data, x)
Base.getproperty(at::Atom, x::Symbol) = hasfield(Atom, x) ? getfield(at, x) : getindex(at.data, x)
function Base.propertynames(at::Atom, private::Bool=false)
    if private
        (fieldnames(Atom)..., keys(at.data)...)
    else
        (filter(!isequal(:data), fieldnames(Atom))..., keys(at.data)...)
    end
end

function Atom(identifier::Union{Symbol,AbstractString,Integer}, position::AbstractVector{L};
              atomic_symbol=Symbol(elements[identifier].symbol),
              atomic_number=elements[identifier].number,
              atomic_mass::M=elements[identifier].atomic_mass,
              kwargs...) where {L <: Unitful.Length, M <: Unitful.Mass}
    Atom{length(position), L, M}(position, atomic_symbol, atomic_number, atomic_mass, Dict(kwargs...))
end
Atom(id_pos::Pair; kwargs...) = Atom(id_pos...; kwargs...)

# Update constructor: Amend any atom by extra data.
function Atom(;atom, kwargs...)
    extra = atom isa Atom ? atom.data : (; )
    Atom(atomic_symbol(atom), position(atom);
         atomic_symbol=atomic_symbol(atom),
         atomic_number=atomic_number(atom),
         atomic_mass=atomic_mass(atom),
         extra..., kwargs...)
end
Atom(atom::Atom; kwargs...) = Atom(; atom, kwargs...)

#
# Special high-level functions to construct atomic systems
#
atomic_system(atoms::AbstractVector{<:Atom}, box, bcs) = FlexibleSystem(atoms, box, bcs)
atomic_system(atoms::AbstractVector, box, bcs) = atomic_system(Atom.(atoms), box, bcs)

function isolated_system(atoms::AbstractVector{<:Atom})
    # Use dummy box and boundary conditions
    D = n_dimensions(first(atoms))
    atomic_system(atoms, infinite_box(D), fill(DirichletZero(), D))
end
isolated_system(atoms::AbstractVector) = isolated_system(Atom.(atoms))

function periodic_system(atoms::AbstractVector,
                         box::AbstractVector{<:AbstractVector},
                         boundary_conditions=fill(Periodic(), length(box));
                         fractional=false, kwargs...)
    lattice = hcat(box...)
    !fractional && return atomic_system(atoms, box, boundary_conditions)

    parse_fractional(atom::Atom) = atom
    function parse_fractional(atom::Pair)
        id, pos_fractional = atom
        Atom(id, lattice * pos_fractional)
    end
    atomic_system(parse_fractional.(atoms), box, boundary_conditions)
end
