
"""
Implementation of a computational cell for particle systems 
   within AtomsBase.jl. `PCell` specifies a parallepiped shaped cell 
   with 
"""
struct PCell{D, T}
   cell_vectors::NTuple{D, SVector{D, T}} 
   pbc::NTuple{D, Bool}
end

bounding_box(cell::PCell) = cell.cell_vectors 

boundary_conditions(cell::PCell) = map(p -> p ? Periodic() : OpenBC(), cell.pbc)

periodicity(cell::PCell) = cell.pbc

isinfinite(cell::PCell) = map(!, cell.pbc)

n_dimensions(::PCell{D}) where {D} = D

# ---------------------- pretty printing 

function Base.show(io::IO, cell::PCell{D}) where {D} 
   u = unit(first(cell.cell_vectors[1][1]))
   print(io, "PCell(", prod(p -> p ? "T" : "F", cell.pbc), ", ")  
   for d = 1:D 
      print(io, ustrip.(cell.cell_vectors[d]), u)
      if d < D; print(io, ", "); end 
   end 
   println(")")
end

function Base.show(io::IO, ::MIME"text/plain", cell::PCell{D}) where {D} 
   u = unit(first(cell.cell_vectors[1][1]))
   println(io, "    PCell(", prod(p -> p ? "T" : "F", cell.pbc), ",")  
   for d = 1:D 
      print(io, "          ", ustrip.(cell.cell_vectors[d]), u)
      d < D && println(",") 
   end 
   println(")")
end


# ---------------------- Constructors 

# different ways to construct cell vectors 

function _auto_cell_vectors(vecs::Tuple) 
   D = length(vecs)
   @assert all(length.(vecs) .== D) "All cell vectors must have the same length"
   return ntuple(i -> SVector{D}(vecs[i]), D)
end

_auto_cell_vectors(vecs::AbstractVector) = 
      _auto_cell_vectors(tuple(vecs...))

# .... could consider allowing construction from a matrix but 
#      that introduced an ambiguity (transpose?) that we may 
#      wish to avoid.       

# different ways to construct PBC 

_auto_pbc1(bc::Bool)   = bc 
_auto_pbc1(::Periodic) = true 
_auto_pbc1(::OpenBC)   = false 
_auto_pbc1(::Nothing)  = false 
_auto_pbc1(::DirichletZero)  = false 

_auto_pbc(bc::Tuple, cell_vectors = nothing) = 
      map(_auto_pbc1, bc)

_auto_pbc(bc::AbstractVector, cell_vectors = nothing) = 
      _auto_pbc(tuple(bc...))

_auto_pbc(bc::Union{Bool, Nothing, BoundaryCondition}, cell_vectors) = 
      ntuple(i -> _auto_pbc1(bc), length(cell_vectors))

# kwarg constructor for PCell

PCell(; cell_vectors, boundary_conditions) = 
      PCell(_auto_cell_vectors(cell_vectors), 
            _auto_pbc(boundary_conditions, cell_vectors))



# ---------------------- 
#  interface functions to connect Systems and cells 

bounding_box(system::SystemWithCell{D, <: PCell}) where {D} = 
   bounding_box(system.cell)

boundary_conditions(system::SystemWithCell{D, <: PCell}) where {D} = 
   boundary_conditions(system.cell)

periodicity(system::SystemWithCell{D, <: PCell}) where {D} = 
   periodicity(system.cell)

isinfinite(system::SystemWithCell{D, <: PCell}) where {D} = 
   isinfinite(system.cell)
