export chemical_formula


"""
Returns the chemical formula of an AbstractSystem as a string.
"""
function chemical_formula(symbols::AbstractVector{Symbol})
    parts = map(collect(Set(symbols))) do sym
        sym_count = count(isequal(sym), symbols)
        sym_count < 2 && return string(sym)

        str_count = string(sym_count)
        for i in 0:9
            str_count = replace(str_count, ('0' + i) => ('₀' + i))  # Make subscripts
        end
        string(sym) * str_count
    end
    join(sort(parts))
end
chemical_formula(system) = chemical_formula(atomic_symbol(system))


function show_system(io::IO, system::AbstractSystem{D}) where {D}
    print(io, "($(chemical_formula(system)), ")
    bc = boundary_conditions(system)
    if all(isequal(bc[1]), bc)
        print(io, typeof(bc[1]), ", ")
    end
    box = bounding_box(system)
    if box != infinite_box(D)
        box_str = ["[" * join(ustrip.(bvector), ", ") * "]" for bvector in box]
        print(io, "box=[", join(box_str, ", "), "]u\"$(unit(box[1][1]))\"")
    else
        print(io, "box=infinite")
    end
    print(io, ")")
end
