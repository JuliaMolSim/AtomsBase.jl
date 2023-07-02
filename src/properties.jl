export chemical_formula

"""
    element_symbol(system)
    element_symbol(system, index)

Return the symbol corresponding to the elmeent of an atom. Note that
this may be different than `atomic_symbol` for cases where `atomic_symbol`
is chosen to be more specific (i.e. designate a special atom).
"""
element_symbol(system::AbstractSystem, i::Integer) = element(atomic_symbol(system, i)).symbol
element_symbol(system::AbstractSystem) = [element(num).symbol for num in atomic_number(system)]
# Note that atomic_symbol cannot be used here, since this may map
# to something more specific than the element


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

chemical_formula(system::AbstractSystem) = chemical_formula(element_symbol(system))
