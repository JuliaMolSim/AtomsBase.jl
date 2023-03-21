#
# A simple view datastructure for atoms of struct of array systems
#
export AtomView

"""
    AtomView{S<:AbstractSystem}

Species type for atoms of systems implemented as struct-of-arrays.
Can be queried with the same API than for other species, like [`Atom`](@ref).

See [FastSystem](@ref Struct-of-Arrays-/-FastSystem) for an example of system
using `AtomView` as its species type.

## Example
```jldoctest; setup=:(using AtomsBase, Unitful; atoms = Atom[:C => [0.25, 0.25, 0.25]u"Å", :C => [0.75, 0.75, 0.75]u"Å"]; box = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]u"Å"; boundary_conditions = [Periodic(), Periodic(), DirichletZero()])
julia> system = FastSystem(atoms, box, boundary_conditions);

julia> atom = system[2]
AtomView(C, atomic_number = 6, atomic_mass = 12.011 u):
    position          : [0.75,0.75,0.75]u"Å"

julia> atom isa AtomView{typeof(system)}
true

julia> atomic_symbol(atom)
:C
```
"""
struct AtomView{S<:AbstractSystem}
    system::S
    index::Int
end

function velocity(v::AtomView)
    vel = velocity(v.system)
    ismissing(vel) && return missing
    return vel[v.index]
end
position(v::AtomView)      = position(v.system)[v.index]
atomic_mass(v::AtomView)   = atomic_mass(v.system)[v.index]
atomic_symbol(v::AtomView) = atomic_symbol(v.system)[v.index]
atomic_number(v::AtomView) = atomic_number(v.system)[v.index]
n_dimensions(v::AtomView)  = n_dimensions(v.system)
element(atom::AtomView)    = element(atomic_number(atom))

Base.show(io::IO, at::AtomView) = show_atom(io, at)
Base.show(io::IO, mime::MIME"text/plain", at::AtomView) = show_atom(io, mime, at)

Base.getindex(v::AtomView, x::Symbol) = getindex(v.system, v.index, x)
Base.haskey(v::AtomView, x::Symbol)   = hasatomkey(v.system, x)
function Base.get(v::AtomView, x::Symbol, default)
    hasatomkey(v.system, x) ? v[x] : default
end
Base.keys(v::AtomView) = atomkeys(v.system)
Base.pairs(at::AtomView) = (k => at[k] for k in keys(at))
