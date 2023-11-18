module AtomsBase
using Unitful
using UnitfulAtomic
using StaticArrays
using Requires

include("interface.jl")
include("properties.jl")
include("visualize_ascii.jl")
include("show.jl")
include("flexible_system.jl")
include("atomview.jl")
include("atom.jl")
include("fast_system.jl")
include("bonded_system.jl")

function __init__()
    @require AtomsView="ee286e10-dd2d-4ff2-afcb-0a3cd50c8041" begin
        function Base.show(io::IO, mime::MIME"text/html", system::FlexibleSystem)
            write(io, AtomsView.visualize_structure(system, mime))
        end
    end
end

end
