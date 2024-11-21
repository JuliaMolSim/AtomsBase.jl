import Base.position
import PeriodicTable

export cell_vectors,
       periodicity,
       cell,
       n_dimensions,
       species,
       position,
       velocity,
       element,
       element_symbol,
       atomic_mass,
       mass,
       atomic_number,
       atomic_symbol,
       atomkeys,
       hasatomkey,
       atom_name


#
# Abstract system
#
"""
    AbstractSystem{D}

A `D`-dimensional particle system.
"""
abstract type AbstractSystem{D} end


# ---------------------------------------------------------------
#   System Properties


"""
    cell_vectors(sys::AbstractSystem{D})

Return a tuple of length `D` of vectors of length `D` that describe the
cell in which the system `sys` is defined.
"""
function cell_vectors end

"""
    set_cell_vectors!(sys::AbstractSystem{D}, bb::NTuple{D, SVector{D, L}})
"""
function set_cell_vectors! end


"""
    periodicity(sys::AbstractSystem{D})

Return a `NTuple{D, Bool}` indicating whether the system is periodic along a
cell vector as specified by `cell_vectors`.
"""
function periodicity end 


"""
    set_periodicity!(sys::AbstractSystem{D}, pbc::NTuple{D, Bool})
"""
function set_periodicity! end 


"""
    cell(sys::AbstractSystem)

Returns the computational cell (domain). 
See e.g. `PeriodicCell` and `IsolatedCell`.
"""
function cell end 

"""
    set_cell!(sys, cell)
"""
function set_cell! end 


# ---------------------------------------------------------------
#   Particle Properties 

"""
    position(sys::AbstractSystem, i)

Return the position of the ith particle if `i` is an `Integer`, a vector of 
positions if `i` is a vector of integers, or a vector of all positions if 
`i == :`.

The return type should be a vector of vectors each containing `D` elements that 
are `<:Unitful.Length`.
"""
function position end 

"""
    set_position!(sys::AbstractSystem{D}, i, x)

- If `i` is an integer then `x` is an `SVector{D, L}` with `L <: Unitful.Length`
- If `i` is an `AbstractVector{<: Integer}` or `:` then `x` is an `AbstractVector{SVector{D, L}}`
"""
function set_position! end 


"""
    mass(sys::AbstractSystem, i)

Mass of a particle if `i::Integer`, vector of masses if `i` is a vector of 
integers or `:`. The elements are `<: Unitful.Mass`.
"""
function mass end 

"""
    set_mass!(sys::AbstractSystem, i, m)

- If `i` is an integer then `m` is a `Unitful.Mass`
- If `i` is an `AbstractVector{<: Integer}` or `:` then `x` is an `AbstractVector{<: Unitful.Mass}`
"""
function set_mass! end 



@deprecate atomic_mass(args...)  mass(args...)


"""
    species(::AbstractSystem, i)

Return the species (type, category, ...) of a particle or particles.
"""
function species end

"""
    set_species!(sys::AbstractSystem, i, s)

- If `i` is an integer then `s` is an object describing the particle species, e.g., `ChemicalSpecies`
- If `i` is an `AbstractVector{<: Integer}` or `:` then `x` is an `AbstractVector` of species objects.
"""
function set_species! end 



"""
    velocity(sys::AbstractSystem, i)

Return a velocity vector if `i::Integer`, a vector of velocities if `i` is a 
vector of integers or `:`. Return type should be a vector of vectors each containing `D` elements that are
`<:Unitful.Velocity`. Returned value of the function may be `missing`.
"""
velocity(sys::AbstractSystem, idx) = missing

"""
    set_velocity!(sys::AbstractSystem, i, v)
"""
function set_velocity! end 



# ---------------------------------------------------------------
#   Derived functionality and prototype implementations 


"""
    n_dimensions(::AbstractSystem)

Return number of dimensions.
"""
n_dimensions(::AbstractSystem{D}) where {D} = D
# Note: Can't use ndims, because that is ndims(sys) == 1 (because of indexing interface)


#  interface functions to connect Systems and cells 

cell_vectors(system::AbstractSystem) = cell_vectors(cell(system))

periodicity(system::AbstractSystem) = periodicity(cell(system))


# ---------------------------------------------------------------
#   Indexing and Iteration interface 


# indexing and iteration interface...need to implement getindex and length, here are default dispatches for others
# default to 1D indexing
Base.size(s::AbstractSystem) = (length(s),)
Base.firstindex(::AbstractSystem) = 1
Base.lastindex(s::AbstractSystem) = length(s)
Base.iterate(sys::AbstractSystem, state = firstindex(sys)) =
    (firstindex(sys) <= state <= length(sys)) ? (@inbounds sys[state], state + 1) : nothing
# Base.eltype(sys::AbstractSystem) = species_type(sys)
Base.collect(s::AbstractSystem) = [ s[i] for i = 1:length(s) ]
Base.getindex(s::AbstractSystem, i::AbstractArray) = getindex.(Ref(s), i)
Base.getindex(s::AbstractSystem, ::Colon) = collect(s)
function Base.getindex(s::AbstractSystem, r::AbstractVector{Bool})
    s[ (firstindex(s):lastindex(s))[r] ]
end

# TODO Support similar, push, ...




# ---------------------------------------------------------------
#   Flexible  dynamic accessors  


"""
    atomkeys(sys::AbstractSystem)

Return the atomic properties, which are available in all atoms of the system.
"""
function atomkeys(system::AbstractSystem)
    atkeys = length(system) == 0 ? () : keys(system[1])
    filter(k -> hasatomkey(system, k), atkeys)
end

"""
    hasatomkey(system::AbstractSystem, x::Symbol)

Returns true whether the passed property available in all atoms of the passed system.
"""
hasatomkey(system::AbstractSystem, x::Symbol) = all(at -> haskey(at, x), system)

# Defaults for system
Base.pairs(system::AbstractSystem) = (k => system[k] for k in keys(system))
function Base.get(system::AbstractSystem, x::Symbol, default)
    haskey(system, x) ? getindex(system, x) : default
end
