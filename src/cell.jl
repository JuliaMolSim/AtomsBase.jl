
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
