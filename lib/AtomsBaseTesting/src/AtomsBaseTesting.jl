module AtomsBaseTesting

using AtomsBase
using Test
using LinearAlgebra
using Unitful
using UnitfulAtomic

using AtomsBase: AbstractSystem

export test_approx_eq
export make_test_system

"""
Test whether two abstract systems are approximately the same. Certain atomic or system
properties can be ignored during the comparison using the respective kwargs.
"""
function test_approx_eq(s::AbstractSystem, t::AbstractSystem;
                        rtol=1e-14, ignore_atprop=Symbol[], ignore_sysprop=Symbol[],
                        common_only=false, quiet=false)
    rnorm(a, b) = (ustrip(norm(a)) < rtol ? norm(a - b) / 1unit(norm(a))
                                          : norm(a - b) / norm(a))

    for method in (length, size, periodicity, )
        @test method(s) == method(t)
    end

    for method in (position, mass)
        @test maximum(map(rnorm, method(s, :), method(t, :))) < rtol
        @test rnorm(method(s, 1), method(t, 1)) < rtol
    end

    # TODO: add element_symbol back in
    for method in (species, atomic_symbol, atomic_number, )
        @test method(s, :) == method(t, :)
        @test method(s, 1) == method(t, 1)
    end

    if !(:velocity in ignore_atprop)
        @test ismissing(velocity(s, :)) == ismissing(velocity(t, :))
        if !ismissing(velocity(s, :)) && !ismissing(velocity(t, :))
            @test maximum(map(rnorm, velocity(s, :), velocity(t, :))) < rtol
            @test rnorm(velocity(s, 1), velocity(t, 1)) < rtol
        end
    end

    # test properties of atoms
    if common_only
        test_atprop = [k for k in atomkeys(s) if hasatomkey(t, k)]
    else
        extra_atomic_props = (:charge, :covalent_radius, :vdw_radius, :magnetic_moment)
        test_atprop = Set([atomkeys(s)..., atomkeys(t)..., extra_atomic_props...])
    end
    for prop in test_atprop
        prop in ignore_atprop && continue
        prop in (:velocity, :position) && continue
        if hasatomkey(s, prop) != hasatomkey(t, prop)
            quiet || println("hashatomkey mismatch for $prop")
            @test hasatomkey(s, prop) == hasatomkey(t, prop)
            continue
        end
        for (at_s, at_t) in zip(s, t)
            @test haskey(at_s, prop) == haskey(at_t, prop)
            if haskey(at_s, prop) && haskey(at_t, prop)
                if at_s[prop] isa Quantity
                    @test rnorm(at_s[prop], at_t[prop]) < rtol
                else
                    @test at_s[prop] == at_t[prop]
                end
            end
        end
    end

    # Test some things on cell objects
    @test periodicity(cell(s))  == periodicity(cell(t))
    @test n_dimensions(cell(s)) == n_dimensions(cell(t))
    if cell(s) isa PeriodicCell
        for (dim, periodic) in enumerate(periodicity(cell(s)))
            if periodic
                @test rnorm(cell_vectors(cell(s))[dim], cell_vectors(cell(t))[dim]) < rtol
            end
        end
    end

    # test properties of systems
    if common_only
        test_sysprop = [k for k in keys(s) if haskey(t, k)]
    else
        extra_system_props = (:charge, :multiplicity)
        test_sysprop = Set([keys(s)..., keys(t)..., extra_system_props...])
    end
    for prop in test_sysprop
        prop in ignore_sysprop && continue
        if haskey(s, prop) != haskey(t, prop)
            quiet || println("haskey mismatch for $prop")
            @test haskey(s, prop) == haskey(t, prop)
            continue
        end
        (haskey(s, prop) && haskey(t, prop)) || continue

        if s[prop] isa Quantity
            @test rnorm(s[prop], t[prop]) < rtol
        elseif prop in (:cell_vectors, ) && (cell(s) isa PeriodicCell)
            @test maximum(map(rnorm, s[prop], t[prop])) < rtol
        else
            @test s[prop] == t[prop]
        end
    end
end


"""
Setup a standard test system using some random data and supply the data to the caller.
Extra atomic or system properties can be specified using `extra_atprop` and `extra_sysprop`
and specific standard keys can be ignored using `drop_atprop` and `drop_sysprop`.
"""
function make_test_system(D=3; drop_atprop=Symbol[], drop_sysprop=Symbol[],
                          extra_atprop=(; ), extra_sysprop=(; ), cellmatrix=:full,
                          n_atoms = 5, )
    @assert D == 3

    if cellmatrix == :lower_triangular
        box = ([1.54732, -0.807289, -0.500870]u"Å",
               [    0.0, 0.4654985, 0.5615117]u"Å",
               [    0.0,       0.0, 0.7928950]u"Å")
    elseif cellmatrix == :upper_triangular
        box = ([1.54732, 0.0, 0.0]u"Å",
               [-0.807289, 0.4654985, 0.0]u"Å",
               [-0.500870, 0.5615117, 0.7928950]u"Å")
    elseif cellmatrix == :diagonal
        box = ([1.54732, 0.0, 0.0]u"Å",
              [0.0, 0.4654985, 0.0]u"Å",
              [0.0, 0.0, 0.7928950]u"Å")
    else
        box = ([1.50304, 0.850344, 0.717239]u"Å",
               [ 0.36113, 1.008144, 0.814712]u"Å",
               [ 0.06828, 0.381122, 2.129081]u"Å")
    end

    # Generate some random data to store in atoms and system
    atprop = Dict{Symbol,Any}(
        :position        => [randn(3) for _ = 1:n_atoms]u"Å",
        :velocity        => [randn(3) for _ = 1:n_atoms] * 10^6*u"m/s",
        #                   Note to above: Reasonable velocity range in au
        :species         => ChemicalSpecies.([:H, :H, :C, :N, :He]),
        :charge          => [2, 1, 3.0, -1.0, 0.0]u"e_au",
        :mass            => 10rand(n_atoms)u"u",
        :vdw_radius      => randn(n_atoms)u"Å",
        :covalent_radius => randn(n_atoms)u"Å",
        :magnetic_moment => [0.0, 0.0, 1.0, -1.0, 0.0],
    )
    sysprop = Dict{Symbol,Any}(
        :cell_vectors => box,
        :periodicity  => (true, true, false),
        #
        :extra_data   => 42,
        :charge       => -1u"e_au",
        :multiplicity => 2,
    )

    for prop in drop_atprop
        pop!(atprop, prop)
    end
    for prop in drop_sysprop
        pop!(sysprop, prop)
    end
    sysprop = merge(sysprop, pairs(extra_sysprop))
    atprop  = merge(atprop,  pairs(extra_atprop))

    atoms = map(1:n_atoms) do i
        atargs = Dict(k => v[i] for (k, v) in pairs(atprop) if !(k in (:position, :velocity)))
        if haskey(atprop, :velocity)
            Atom(atprop[:species][i], atprop[:position][i], atprop[:velocity][i]; atargs...)
        else
            Atom(atprop[:species][i], atprop[:position][i]; atargs...)
        end
    end
    cell = PeriodicCell(; cell_vectors=sysprop[:cell_vectors],
                          periodicity=sysprop[:periodicity])

    sysargs = Dict(k => v for (k, v) in pairs(sysprop)
                   if !(k in (:cell_vectors, :periodicity)))
    system = FlexibleSystem(atoms, cell; sysargs...)

    (; system, atoms, cell,
       cell_vectors=sysprop[:cell_vectors],
       periodicity=sysprop[:periodicity],
       atprop=NamedTuple(atprop),
       sysprop=NamedTuple(sysprop))
end

end
