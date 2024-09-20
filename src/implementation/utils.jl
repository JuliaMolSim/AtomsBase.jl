

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
                                  bounding_box, pbcs)
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
function isolated_system(atoms::AbstractVector{<:Atom}; kwargs...) 
    𝐫 = position(atoms[1])
    D = length(𝐫)
    T = eltype(𝐫[1])
    return FlexibleSystem(atoms, IsolatedCell(D, T); kwargs...)
end

isolated_system(atoms::AbstractVector; kwargs...) = 
      isolated_system(convert.(Atom, atoms); kwargs...)


"""
    periodic_system(atoms::AbstractVector, box; fractional=false, kwargs...)

Construct a [`FlexibleSystem`](@ref) with all boundaries of the `box` periodic
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
julia> box = 10.26 / 2 * [[0, 0, 1], [1, 0, 1], [1, 1, 0]]u"bohr"
julia> silicon = periodic_system([:Si =>  ones(3)/8,
                                  :Si => -ones(3)/8],
                                 box, fractional=true)
```
"""
function periodic_system(atoms::AbstractVector,
                         box::AUTOBOX;
                         fractional=false, kwargs...)
    lattice = _auto_cell_vectors(box)
    pbcs = fill(true, length(lattice))
    !fractional && return atomic_system(atoms, lattice, pbcs; kwargs...)

    parse_fractional(atom::Atom) = atom
    function parse_fractional(atom::Pair)::Atom
        id, pos_fractional = atom
        Atom(id, sum(lattice .* pos_fractional))
    end
    atomic_system(parse_fractional.(atoms), lattice, pbcs; kwargs...)
end

