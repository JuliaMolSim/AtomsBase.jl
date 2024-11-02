using Printf
using Preferences

"""
Configures the printing behaviour of `show_system`, which is invoked when a rich `text/plain`
display of an `AbstractSystem` is requested. This is for example the case in a Julia REPL.
The following options can be configured:

- `max_particles_list`: Maximal number of particles in a system until `show_system`
  includes a listing of every particle. Default: 10
- `max_particles_visualize_ascii`: Maximal number of particles in a system
  until `show_system` includes a representation of the system in the form of
  an ascii cartoon using `visualize_ascii`. Default 0, i.e. disabled.
"""
function set_show_preferences!(; max_particles_list=nothing, max_particles_visualize_ascii=nothing)
    if !isnothing(max_particles_list)
        @set_preferences!("max_particles_list" => max_particles_list)
    end
    if !isnothing(max_particles_visualize_ascii)
        @set_preferences!("max_particles_visualize_ascii" => max_particles_visualize_ascii)
    end
    show_preferences()
end

"""
Display the current printing behaviour of `show_system`.
See [`set_show_preferences!](@ref) for more details on the keys.
"""
function show_preferences()
    (; max_particles_list=@load_preference("max_particles_list", 10),
       max_particles_visualize_ascii=@load_preference("max_particles_visualize_ascii", 0))
end

"""
Suggested function to print AbstractSystem objects to screen
"""
function show_system(io::IO, system::AbstractSystem{D}) where {D}
    pbc = periodicity(system)
    print(io, typeof(system).name.name, "($(chemical_formula(system))")
    perstr = [p ? "T" : "F" for p in pbc]
    print(io, ", pbc = ", join(perstr, ""))

    if !any(pbc)
        box_str = ["[" * join(ustrip.(bvector), ", ") * "]"
                   for bvector in cell_vectors(system)]
        bunit = unit(eltype(first(cell_vectors(system))))
        print(io, ", cell_vectors = [", join(box_str, ", "), "]u\"$bunit\"")
    end
    print(io, ")")
end

function show_system(io::IO, ::MIME"text/plain", system::AbstractSystem{D}) where {D}
    pbc  = periodicity(system)
    print(io, typeof(system).name.name, "($(chemical_formula(system))")
    perstr = [p ? "T" : "F" for p in periodicity(system)]
    print(io, ", pbc = ", join(perstr, ""))
    println(io, "):")

    extra_line = false
    if any(pbc)
        extra_line = true
        box = cell_vectors(system)
        bunit = unit(eltype(first(cell_vectors(system))))
        for (i, bvector) in enumerate(box)
            if i == 1
                @printf io "    %-17s : [" "cell_vectors"
            else
                print(io, " "^25)
            end
            boxstr = [(@sprintf "%8.6g" ustrip(b)) for b in bvector]
            print(io, join(boxstr, " "))
            println(io, i == D ? "]u\"$bunit\"" : ";")
        end
    end

    for (k, v) in pairs(system)
        k in (:cell_vectors, :periodicity) && continue
        extra_line = true
        @printf io "    %-17s : %s\n" string(k) string(v)
    end
    if length(system) ≤ show_preferences().max_particles_list
        extra_line && println(io)
        for atom in system
            println(io, "    ", atom)
        end
        extra_line = true
    end

    if length(system) ≤ show_preferences().max_particles_visualize_ascii
        ascii = visualize_ascii(system)
        if !isempty(ascii)
            extra_line && println(io)
            println(io, "   ", replace(ascii, "\n" => "\n   "))
        end
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
    println(io, atomic_symbol(at), ", Z = ", atomic_number(at),
            ", m = ", mass(at), "):")

    pos = [(@sprintf "%.8g" ustrip(p)) for p in position(at)]
    posunit = unit(eltype(position(at)))
    @printf io "    %-17s : [%s]u\"%s\"\n" "position" join(pos, ",") string(posunit)
    if !ismissing(velocity(at)) && !iszero(velocity(at))
        vel = [(@sprintf "%.8g" ustrip(p)) for p in velocity(at)]
        velunit = unit(eltype(velocity(at)))
        @printf io "    %-17s : [%s]u\"%s\"\n" "velocity" join(vel, ",") string(velunit)
    end
    for (k, v) in pairs(at)
        k in (:atomic_number, :mass, :atomic_symbol, :position, :velocity) && continue
        @printf io "    %-17s : %s\n" string(k) string(v)
    end
end
