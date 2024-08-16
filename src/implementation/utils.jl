

#
# Special high-level functions to construct atomic systems
#

export atomic_system, isolated_system, periodic_system

"""
    atomic_system(atoms::AbstractVector, bounding_box, periodicity; kwargs...)

Construct a [`FlexibleSystem`](@ref) using the passed `atoms` and boundary box and conditions.
Extra `kwargs` are stored as custom system properties.

# Examples
Construct a hydrogen molecule in a box, which is periodic only in the first two dimensions
```julia-repl
julia> bounding_box = [[10.0, 0.0, 0.0], [0.0, 10.0, 0.0], [0.0, 0.0, 10.0]]u"Å"
julia> pbcs = (true, true, false)
julia> hydrogen = atomic_system([:H => [0, 0, 1.]u"bohr",
                                 :H => [0, 0, 3.]u"bohr"],
                                  bounding_box, pubcs)
```
"""
atomic_system(atoms::AbstractVector{<:Atom}, box, bcs; kwargs...) = 
      FlexibleSystem(atoms, box, bcs; kwargs...)

atomic_system(atoms::AbstractVector, box, bcs; kwargs...) = 
      FlexibleSystem(convert.(Atom, atoms), box, bcs; kwargs...)


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
isolated_system(atoms::AbstractVector{<:Atom}; kwargs...) = 
      FlexibleSystem(atoms, OpenSystemCell(); kwargs...)

isolated_system(atoms::AbstractVector; kwargs...) = 
      isolated_system(convert.(Atom, atoms); kwargs...)


"""
    periodic_system(atoms::AbstractVector, bounding_box; fractional=false, kwargs...)

Construct a [`FlexibleSystem`](@ref) with all boundaries of the `bounding_box` periodic
(standard setup for modelling solid-state systems). If `fractional` is true, atom coordinates
are given in fractional (and not in Cartesian) coordinates.
Extra `kwargs` are stored as custom system properties.

# Examples
Setup a hydrogen molecule inside periodic BCs:
```julia-repl
julia> bounding_box = ([10.0, 0.0, 0.0]u"Å", [0.0, 10.0, 0.0]u"Å", [0.0, 0.0, 10.0]u"Å")
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
                         box::Union{Tuple, AbstractVector};
                         fractional=false, kwargs...)
    pbcs = fill(true, length(box))
    lattice = tuple(box...)
    !fractional && return atomic_system(atoms, box, pbcs; kwargs...)

    parse_fractional(atom::Atom) = atom
    function parse_fractional(atom::Pair)::Atom
        id, pos_fractional = atom
        Atom(id, sum(lattice .* pos_fractional))
    end
    atomic_system(parse_fractional.(atoms), box, pbcs; kwargs...)
end

