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
