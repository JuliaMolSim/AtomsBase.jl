using Test


function potential_energy end 

function forces end 

function forces! end 

function virial end 

function energy_forces(system, calculator; kwargs...)
    e = potential_energy(system, calculator; kwargs...)
    f = forces(system, calculator; kwargs...)
    return (;
        :energy => e,
        :forces => f
    )
end 

function energy_forces!(f::AbstractVector, system, calculator; kwargs...)
    e = potential_energy(system, calculator; kwargs...)
    forces!(f, system, calculator; kwargs...)
    return (;
        :energy => e,
        :forces => f
    )
end 

function energy_forces_virial(system, calculator; kwargs...)
    ef = energy_forces(system, calculator; kwargs...)
    v = virial(system, calculator; kwargs...)
    return (;
        :energy => ef[:energy],
        :forces => ef[:forces],
        :virial => v
    )
end 

function energy_forces_virial!(f::AbstractVector, system, calculator; kwargs...)
    ef = energy_forces!(f, system, calculator; kwargs)
    v = virial(system, calculator; kwargs...)
    return (;
        :energy => ef[:energy],
        :forces => ef[:forces],
        :virial => v
    )
end 


const default_force_eltype = SVector(1., 1., 1.) * u"eV/Å" |> typeof

"""
    @generate_complement

Gnereate complementary function for given function expression.
This is intended to generate non-allocating force call from
allocating force call and viseversa.
"""
macro generate_complement(expr)
    oldname = nothing
    try
        oldname = "$(expr.args[1].args[1])"
    catch _
        error("Not valid input")
    end

    try
        has_kwargs = any( [ Symbol("...") == x.head  for x in expr.args[1].args[2].args ] )
        !has_kwargs && error()
    catch _
        error("Call does not catch kwargs...")
    end

    calc_type = nothing
    try
        calc_type = expr.args[1].args[end].args[2]
    catch _
        throw(error("Calculator does not have defined type"))
    end

    if oldname[end] == '!'
        length(expr.args[1].args) != 5 && error("Number of inputs does not match the call")
        name = oldname[begin:end-1] 
        q = Meta.parse(
            "function $name(system, calculator::$calc_type; kwargs...)
                final_data = zeros( default_force_eltype, length(system) )
                $oldname(final_data, system, calculator; kwargs...)
                return final_data
            end"
        )  
    else
        length(expr.args[1].args) != 4 && error("Number of inputs does not match the call")
        name = oldname * "!"
        q = Meta.parse(
            "function $name(final_data::AbstractVector, system, calculator::$calc_type; kwargs...)
                @assert length(final_data) == length(system)
                final_data .= $oldname(system, calculator; kwargs...)
                return final_data
            end"
        )
    end
    return quote
        $expr
        $q
    end
end


function test_forces(sys, calculator; force_eltype=default_force_eltype, kwargs...)
    @testset "Test forces for $(typeof(calculator))" begin
        f = AtomsBase.forces(sys, calculator; kwargs...)
        @test typeof(f) <: AbstractVector
        @test eltype(f) <: AbstractVector
        @test length(f) == length(sys)
        T = (eltype ∘ eltype)( f )
        f_matrix = reinterpret(reshape, T, f)
        @test typeof(f_matrix) <: AbstractMatrix
        @test eltype(f_matrix) <: Number
        @test size(f_matrix) == (3, length(f))
        @test all( AtomsBase.forces(sys, calculator; dummy_kword659234=1, kwargs...) .≈ f )
        @test dimension(f[1][1]) == dimension(u"N")
        @test length(f[1]) == (length ∘ position)(sys,1)
        f_nonallocating = zeros(force_eltype, length(f))
        AtomsBase.forces!(f_nonallocating, sys, calculator; kwargs...)
        @test all( f_nonallocating .≈ f  )
        AtomsBase.forces!(f_nonallocating, sys, calculator; dummy_kword659254=1, kwargs...)
        @test all( f_nonallocating .≈ f  )
    end
end


function test_potential_energy(sys, calculator; kwargs...)
    @testset "Test potential_energy for $(typeof(calculator))" begin
        e = AtomsBase.potential_energy(sys, calculator; kwargs...)
        @test typeof(e) <: Number
        @test dimension(e) == dimension(u"J")
        e2 = AtomsBase.potential_energy(sys, calculator; dummy_kword6594254=1, kwargs...)
        @test e ≈ e2
    end
end


function test_virial(sys, calculator; kwargs...)
    @testset "Test virial for $(typeof(calculator))" begin
        v = AtomsBase.virial(sys, calculator; kwargs...)
        @test typeof(v) <: AbstractMatrix
        @test eltype(v) <: Number
        @test dimension(v[begin]) == dimension(u"J*m")
        l = (length ∘ position)(sys,1) 
        @test size(v) == (l,l) # allow different dimensions than 3
        v2 = AtomsBase.virial(sys, calculator; dummy_kword6594254=1, kwargs...)
        @test all( v .≈ v2 )
    end
end
