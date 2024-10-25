
export IsolatedCell, 
       PeriodicCell


# ------------------------------------------------------------------ 
#     IsolatedCell 
# ------------------------------------------------------------------ 

"""
      IsolatedCell{D, T}

Defines a computational domain / cell describing an open system.
"""
struct IsolatedCell{D, T} end

IsolatedCell(D, T = typeof(1.0 * u"bohr")) =
      IsolatedCell{D, T}()

bounding_box(cell::IsolatedCell{D, T}) where {D, T} =
      ntuple(i -> SVector(ntuple(j -> i == j ? T(Inf) : zero(T), D)...), D)

periodicity(cell::IsolatedCell{D}) where {D} =
      ntuple(_ -> false, D)

n_dimensions(::IsolatedCell{D}) where {D} = D



# ------------------------------------------------------------------ 
#     PeriodicCell (periodic parallepiped) 
# ------------------------------------------------------------------ 

"""
Implementation of a computational cell for particle systems
within AtomsBase.jl. `PeriodicCell` specifies a parallepiped shaped cell
with choice of open or periodic boundary condition in each cell
vector direction.
"""
struct PeriodicCell{D, T}
   bounding_box::NTuple{D, SVector{D, T}}
   periodicity::NTuple{D, Bool}
end

bounding_box(cell::PeriodicCell) = cell.bounding_box

periodicity(cell::PeriodicCell) = cell.periodicity

n_dimensions(::PeriodicCell{D}) where {D} = D

# kwarg constructor for PeriodicCell

function PeriodicCell(; bounding_box=nothing, periodicity, cell_vectors=nothing)
    !isnothing(cell_vectors) && @warn "cell_vectors kwarg is deprecated and will be removed"
    bounding_box = something(cell_vectors, bounding_box)
    PeriodicCell(_auto_bounding_box(bounding_box),
                 _auto_pbc(periodicity, bounding_box))
end

PeriodicCell(cl::Union{AbstractSystem, PeriodicCell}) =
         PeriodicCell(; bounding_box = bounding_box(cl),
                        periodicity = periodicity(cl) )

# ---------------------- pretty printing

function Base.show(io::IO, cϵll::PeriodicCell{D}) where {D}
   u = unit(first(cϵll.bounding_box[1][1]))
   print(io, "PeriodicCell(", prod(p -> p ? "T" : "F", periodicity(cϵll)), ", ")
   for d = 1:D 
      print(io, ustrip.(cϵll.bounding_box[d]), u)
      if d < D; print(io, ", "); end 
   end 
   print(")")
end



# ---------------------------------------------
#     Utilities

# allowed input types that convert automatically to the 
# intended format for cell vectors,  NTuple{D, SVector{D, T}}
const AUTOBOX = Union{NTuple{D, <: AbstractVector}, 
                      AbstractVector{<: AbstractVector}} where {D}

# allowed input types that convert automatically to the 
# intended format for pbc,  NTuple{D, Bool}
const AUTOPBC = Union{Bool,
                      NTuple{D, Bool},
                      AbstractVector{<: Bool}} where {D} 

# different ways to construct cell vectors

function _auto_bounding_box(vecs::Tuple)
   D = length(vecs)
   if !all(length.(vecs) .== D)
      throw(ArgumentError("All cell vectors must have the same length"))
   end
   return ntuple(i -> SVector{D}(vecs[i]), D)
end

_auto_bounding_box(vecs::AbstractVector{<: AbstractVector}) =
      _auto_bounding_box(tuple(vecs...))

# .... could consider allowing construction from a matrix but
#      that introduced an ambiguity (transpose?) that we may
#      wish to avoid.

# different ways to construct PBC

_auto_pbc1(pbc::Bool)  = pbc
_auto_pbc1(::Nothing)  = false

_auto_pbc(bc::Tuple, bounding_box = nothing) =
      map(_auto_pbc1, bc)

_auto_pbc(bc::AbstractVector, bounding_box = nothing) =
      _auto_pbc(tuple(bc...))

_auto_pbc(bc::Union{Bool, Nothing}, bounding_box) =
      ntuple(i -> _auto_pbc1(bc), length(bounding_box))


# infinite box could use Inf for thebounding box vectors e.g. as follows
# NOTE: this used to be exported, but I don't see the rationale for this

_infinite_box(::Val{D}, T) where {D} =
      ntuple(i -> SVector(ntuple(j -> (i == j) ? T(Inf) : zero(T), D)...), D)
