#
# A simple view datastructure for atoms of struct of array systems
#
export AtomView
struct AtomView{FS <: AbstractSystem}
    system::FS
    index::Int
end
velocity(v::AtomView)      = missing
position(v::AtomView)      = position(v.system, v.index)
atomic_mass(v::AtomView)   = atomic_mass(v.system, v.index)
atomic_symbol(v::AtomView) = atomic_symbol(v.system, v.index)
atomic_number(v::AtomView) = atomic_number(v.system, v.index)
element(v::AtomView)       = elements[atomic_symbol(v)]
n_dimensions(v::AtomView)  = n_dimensions(v.system)
