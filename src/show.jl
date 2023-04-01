using Printf

"""
Suggested function to print AbstractSystem objects to screen
"""
function show_system(io::IO, system::AbstractSystem{D}) where {D}
    bc  = boundary_conditions(system)

    print(io, typeof(system).name.name, "($(chemical_formula(system))")
    if isinfinite(system)
        print(io, ", infinite")
    else
        perstr = [p ? "T" : "F" for p in periodicity(system)]
        print(io, ", periodic = ", join(perstr, ""))
    end

    if !isinfinite(system)
        box_str = ["[" * join(ustrip.(bvector), ", ") * "]"
                   for bvector in bounding_box(system)]
        bunit = unit(eltype(first(bounding_box(system))))
        print(io, ", bounding_box = [", join(box_str, ", "), "]u\"$bunit\"")
    end
    print(io, ")")
end
function show_system(io::IO, ::MIME"text/plain", system::AbstractSystem{D}) where {D}
    bc  = boundary_conditions(system)
    box = bounding_box(system)
    print(io, typeof(system).name.name, "($(chemical_formula(system))")
    if isinfinite(system)
        print(io, ", infinite")
    else
        perstr = [p ? "T" : "F" for p in periodicity(system)]
        print(io, ", periodic = ", join(perstr, ""))
    end
    println(io, "):")

    extra_line = false
    if !isinfinite(system)
        extra_line = true
        box = bounding_box(system)
        bunit = unit(eltype(first(bounding_box(system))))
        for (i, bvector) in enumerate(box)
            if i == 1
                @printf io "    %-17s : [" "bounding_box"
            else
                print(io, " "^25)
            end
            boxstr = [(@sprintf "%8.6g" ustrip(b)) for b in bvector]
            print(io, join(boxstr, " "))
            println(io, i == D ? "]u\"$bunit\"" : ";")
        end
    end

    for (k, v) in pairs(system)
        k in (:bounding_box, :boundary_conditions) && continue
        extra_line = true
        @printf io "    %-17s : %s\n" string(k) string(v)
    end
    if length(system) < 10
        extra_line && println(io)
        for atom in system
            println(io, "    ", atom)
        end
        extra_line = true
    end

    ascii_string = ascii_structure(system)
    if !isempty(ascii_string)
        extra_line && println(io)
        println(io, "   ", replace(ascii_string, "\n" => "\n   "))
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
    println(io, atomic_symbol(at), ", atomic_number = ", atomic_number(at),
            ", atomic_mass = ", atomic_mass(at), "):")

    pos = [(@sprintf "%.8g" ustrip(p)) for p in position(at)]
    posunit = unit(eltype(position(at)))
    @printf io "    %-17s : [%s]u\"%s\"\n" "position" join(pos, ",") string(posunit)
    if !ismissing(velocity(at)) && !iszero(velocity(at))
        vel = [(@sprintf "%.8g" ustrip(p)) for p in velocity(at)]
        velunit = unit(eltype(velocity(at)))
        @printf io "    %-17s : [%s]u\"%s\"\n" "velocity" join(vel, ",") string(velunit)
    end
    for (k, v) in pairs(at)
        k in (:atomic_number, :atomic_mass, :atomic_symbol, :position, :velocity) && continue
        @printf io "    %-17s : %s\n" string(k) string(v)
    end
end
