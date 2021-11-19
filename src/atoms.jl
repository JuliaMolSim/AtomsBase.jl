#
# Extra stuff only for Systems composed of atoms
#

export StaticAtom, AbstractAtomicSystem
export atomic_mass, atomic_number, atomic_symbol, atomic_property

struct StaticAtom{D,L<:Unitful.Length}
    position::SVector{D,L}
    element::Element
end
StaticAtom(position, element) = StaticAtom{length(position)}(position, element)
position(atom::StaticAtom) = atom.position
species(atom::StaticAtom) = atom.element
velocity(::StaticAtom) = missing

function StaticAtom(position, symbol::Union{Integer,AbstractString,Symbol,AbstractVector})
    StaticAtom(position, elements[symbol])
end

function Base.show(io::IO, a::StaticAtom)
    print(io, "StaticAtom: $(a.element.symbol)")
end

const AbstractAtomicSystem{D} = AbstractSystem{D,Element}

atomic_symbol(a::StaticAtom) = a.element.symbol
atomic_mass(a::StaticAtom) = a.element.atomic_mass
atomic_number(a::StaticAtom) = a.element.number
atomic_property(a::StaticAtom, property::Symbol) = getproperty(a.element, property)

atomic_symbol(sys::AbstractAtomicSystem) = atomic_symbol.(sys)
atomic_number(sys::AbstractAtomicSystem) = atomic_number.(sys)
atomic_mass(sys::AbstractAtomicSystem) = atomic_mass.(sys)
atomic_property(sys::AbstractAtomicSystem, property::Symbol)::Vector{Any} =
    atomic_property.(sys, property)
