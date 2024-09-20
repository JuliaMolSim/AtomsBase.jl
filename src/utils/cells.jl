
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
   cell_vectors::NTuple{D, SVector{D, T}} 
   periodicity::NTuple{D, Bool}
end

bounding_box(cell::PeriodicCell) = cell.cell_vectors 

periodicity(cell::PeriodicCell) = cell.periodicity

n_dimensions(::PeriodicCell{D}) where {D} = D

# kwarg constructor for PeriodicCell

PeriodicCell(; cell_vectors, periodicity) = 
      PeriodicCell(_auto_cell_vectors(cell_vectors), 
            _auto_pbc(periodicity, cell_vectors))

PeriodicCell(cl::Union{AbstractSystem, PeriodicCell}) = 
         PeriodicCell(; cell_vectors = bounding_box(cl), 
                        periodicity = periodicity(cl) )

# ---------------------- pretty printing 

function Base.show(io::IO, cϵll::PeriodicCell{D}) where {D} 
   u = unit(first(cϵll.cell_vectors[1][1]))
   print(io, "PeriodicCell(", prod(p -> p ? "T" : "F", periodicity(cϵll)), ", ")
   for d = 1:D 
      print(io, ustrip.(cϵll.cell_vectors[d]), u)
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

function _auto_cell_vectors(vecs::Tuple) 
   D = length(vecs)
   if !all(length.(vecs) .== D)
      throw(ArgumentError("All cell vectors must have the same length"))
   end
   return ntuple(i -> SVector{D}(vecs[i]), D)
end

_auto_cell_vectors(vecs::AbstractVector{<: AbstractVector}) = 
      _auto_cell_vectors(tuple(vecs...))

# .... could consider allowing construction from a matrix but 
#      that introduced an ambiguity (transpose?) that we may 
#      wish to avoid.       

# different ways to construct PBC 

_auto_pbc1(pbc::Bool)  = pbc 
_auto_pbc1(::Nothing)  = false 

_auto_pbc(bc::Tuple, cell_vectors = nothing) = 
      map(_auto_pbc1, bc)

_auto_pbc(bc::AbstractVector, cell_vectors = nothing) = 
      _auto_pbc(tuple(bc...))

_auto_pbc(bc::Union{Bool, Nothing}, cell_vectors) = 
      ntuple(i -> _auto_pbc1(bc), length(cell_vectors))


# infinite box could use Inf for thebounding box vectors e.g. as follows
# NOTE: this used to be exported, but I don't see the rationale for this

_infinite_box(::Val{D}, T) where {D} = 
      ntuple(i -> SVector(ntuple(j -> (i == j) ? T(Inf) : zero(T), D)...), D)
