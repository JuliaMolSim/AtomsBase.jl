module AtomsBase

using Unitful
using UnitfulAtomic
using StaticArrays
using Requires

export Atom, FlexibleSystem, FastSystem, AbstractSystem

# Main Interface specification and inline docs
include("interface.jl")

# utilities useful to share across implementations
include("utils/cells.jl")
include("utils/chemspecies.jl")
include("utils/properties.jl")
include("utils/visualize_ascii.jl")
include("utils/show.jl")
include("utils/atomview.jl")

# prototype implementations
include("implementation/atom.jl")
include("implementation/flexible_system.jl")
include("implementation/fast_system.jl")
include("implementation/utils.jl")

end
