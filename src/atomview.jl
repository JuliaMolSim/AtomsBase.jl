#
# A simple view datastructure for atoms of struct of array systems
#
export AtomView
struct AtomView{FS <: AbstractSystem}
    system::FS
    index::Int
end
velocity(v::AtomView)      = velocity(v.system, v.index)
position(v::AtomView)      = position(v.system, v.index)
atomic_mass(v::AtomView)   = atomic_mass(v.system, v.index)
atomic_symbol(v::AtomView) = atomic_symbol(v.system, v.index)
atomic_number(v::AtomView) = atomic_number(v.system, v.index)
n_dimensions(v::AtomView)  = n_dimensions(v.system)
element(atom::AtomView)    = element(atomic_number(atom))

Base.show(io::IO, at::AtomView) = show_atom(io, at)
Base.show(io::IO, mime::MIME"text/plain", at::AtomView) = show_atom(io, mime, at)
