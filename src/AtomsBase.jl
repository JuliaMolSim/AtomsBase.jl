module AtomsBase

using Unitful
using UnitfulAtomic
using StaticArrays
using Requires

export Atom, FlexibleSystem, FastSystem

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


# TODO: 
#  - this should be converted to an extension 
#  - should work for AbstractSystem
function __init__()
    @require AtomsView="ee286e10-dd2d-4ff2-afcb-0a3cd50c8041" begin
        function Base.show(io::IO, mime::MIME"text/html", system::FlexibleSystem)
            write(io, AtomsView.visualize_structure(system, mime))
        end
    end
end


end
