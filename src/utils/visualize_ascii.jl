using UnitfulAtomic
using LinearAlgebra

export visualize_ascii

"""
Build an ASCII representation of the passed atomistic structure. The string may
be empty if the passed structure could not be represented
(structure not supported or invalid).
"""
function visualize_ascii(system::AbstractSystem{D}) where {D}
    # Heavily inspired by the ascii art plot algorithm of GPAW
    # See output.py in the GPAW sources

    # Unit cell matrix (vectors column-by-column) and plotting box (xyz)
    cell  = austrip.(reduce(hcat, bounding_box(system)))
    box   = Vector(diag(cell))
    shift = zero(box)
    plot_box = D > 1

    is_right_handed = det(cell) > 0
    is_right_handed || return ""

    is_orthorhombic = isdiag(cell)
    if !is_orthorhombic
        # Build an orthorhombic cell inscribing the actual unit cell
        # by lumping each cartesian component on the diagonal
        box = sum.(eachrow(cell))

        # Shift centre of the original unit cell to the centre of the orthorhomic cell
        centre_atoms = austrip.(sum(position(system)) / length(system))
        shift = box / 2 - centre_atoms

        plot_box = false
    end

    # If one of the box coordinates is negative 
    any(box .≤ 0) && return ""

    # Normalise positions
    normpos = [@. box * mod((shift + austrip(p)) / box, 1.0)
               for p in position(system)]

    scaling = 1.3
    sx = nothing
    sy = nothing
    sz = nothing
    canvas = nothing
    while scaling > 0.1
        if D == 2
            scaled = scaling .* [box[1], 0.0, box[2]]
        else
            scaled = scaling .* box .* (1.0, 0.25, 0.5)
        end

        sx, sy, sz = round.(Int, scaled)
        canvas = fill(' ', sx + sy + 4, sy + sz + 1)
        all(size(canvas) .≤ 100) && break
        scaling *= 0.9
    end

    if D == 2
        projector = Diagonal([sx sz] ./ box)
    elseif D == 3
        projector = [sx sy 0; 0 sy sz] * Diagonal(1 ./ box)
    end
    pos2d = [1 .+ round.(Int, projector * p .+ eps(Float64)) for p in normpos]

    # Draw box onto canvas
    if plot_box
        # 7 Corners:
        canvas[2      + sy, 1 + sy     ] = '.'
        canvas[2 + sx + sy, 1 + sy     ] = '.'
        canvas[2 + sx + sy, 1 + sy + sz] = '.'
        canvas[2 + sy,      1 + sy + sz] = '.'
        canvas[2,           1          ] = '*'
        canvas[2 + sx,      1          ] = '*'
        canvas[2,           1      + sz] = '*'
        if D < 3  # Better use a *
            canvas[2 + sx + sy, 1 + sy + sz] = '*'
        end

        for y in 1:sy-1  # Bars along y
            canvas[2 + y,      1 + y     ] = '/'
            canvas[2 + y + sx, 1 + y     ] = '/'
            canvas[2 + y,      1 + y + sz] = '/'
        end

        for z in 1:sz-1
            canvas[2,           1      + z] = '|'
            canvas[2 + sy,      1 + sy + z] = '|'
            canvas[2 + sx + sy, 1 + sy + z] = '|'
        end

        for x in 1:sx-1  # Bars along x
            canvas[2 + x,      1          ] = '-'
            canvas[2 + x + sy, 1 + sy     ] = '-'
            canvas[2 + x + sy, 1 + sy + sz] = '-'
        end
    end

    depth2d = Inf * ones(size(canvas))  # Keep track of things covering each other
    for (iatom, symbol) in enumerate(atomic_symbol(system))
        x, y = pos2d[iatom]
        for (i, c) in enumerate(string(symbol))
            if normpos[iatom][2] < depth2d[x + i, y]
                canvas[x + i, y]  = c
                depth2d[x + i, y] = normpos[iatom][2]
            end
        end
    end

    join(reverse([join(col) for col in eachcol(canvas)]), "\n")
end
visualize_ascii(::AbstractSystem{1}) = ""
