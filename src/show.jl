using Printf

"""
Suggested function to print AbstractSystem objects to screen
"""
function show_system(io::IO, system::AbstractSystem{D}) where {D}
    print(io, typeof(system).name.name, "($(chemical_formula(system)), ")
    print(io, repr(get_cell(system)))
    print(io, ")")
end

function show_system(io::IO, mime::MIME"text/plain", system::AbstractSystem{D}) where {D}
    println(io, typeof(system).name.name, "($(chemical_formula(system))")
    print(io, mime, get_cell(system))

    if length(system) < 10
        for atom in system
            println(io, "    ", atom)
        end
        extra_line = true
    end

    ascii = visualize_ascii(system)
    if !isempty(ascii)
        extra_line && println(io)
        println(io, "   ", replace(ascii, "\n" => "\n   "))
    end
end

Base.show(io::IO, system::AbstractSystem) = show_system(io, system)
function Base.show(io::IO, mime::MIME"text/plain", system::AbstractSystem)
    show_system(io, mime, system)
end

function show_atom(io::IO, at)
    pos = [(@sprintf "%8.6g" ustrip(p)) for p in position(at)]
    posunit = unit(eltype(position(at)))
    print(io, typeof(at).name.name, "(")
    print(io, (@sprintf "%-3s" (string(atomic_symbol(at))) * ","), " [",
          join(pos, ", "), "]u\"$posunit\"")
    if ismissing(velocity(at)) || iszero(velocity(at))
        print(io, ")")
    else
        vel = [(@sprintf "%8.6g" ustrip(p)) for p in velocity(at)]
        velunit = unit(eltype(velocity(at)))
        print(io, ", [", join(vel, ", "), "]u\"$velunit\")")
    end
end

function show_atom(io::IO, ::MIME"text/plain", at)
    print(io, typeof(at).name.name, "(")
    println(io, atomic_symbol(at), ", atomic_mass = ", atomic_mass(at), "): ")

    pos = [(@sprintf "%.8g" ustrip(p)) for p in position(at)]
    posunit = unit(eltype(position(at)))
    @printf io "     %-17s : [%s]u\"%s\"\n" "position" join(pos, ",") string(posunit)
    if !ismissing(velocity(at)) && !iszero(velocity(at))
        vel = [(@sprintf "%.8g" ustrip(p)) for p in velocity(at)]
        velunit = unit(eltype(velocity(at)))
        @printf io "    %-17s : [%s]u\"%s\"\n" "velocity" join(vel, ",") string(velunit)
    end
    for (k, v) in pairs(at)
        k in (:atomic_number, :atomic_mass, :atomic_symbol, :chemical_element, :position, :velocity) && continue
        @printf io "     %-17s : %s\n" string(k) string(v)
    end
end
