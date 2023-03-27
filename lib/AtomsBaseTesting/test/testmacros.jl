# This file extends
# https://github.com/JuliaLang/julia/blob/7c8cbf68865c7a8080a43321c99e07224f614e69/stdlib/Test/test/nothrow_testset.jl
# which is under an MIT licence.

using Test

mutable struct NoThrowTestSet <: Test.AbstractTestSet
    results::Vector
    NoThrowTestSet(desc) = new([])
end
Test.record(ts::NoThrowTestSet, t::Test.Result) = (push!(ts.results, t); t)
Test.finish(ts::NoThrowTestSet) = ts.results


macro testpass(expr)
    quote
        local ts = @testset NoThrowTestSet begin
            $(esc(expr))
        end
        @test  all(t -> t isa Test.Pass,  ts)
    end
end

macro testfail(expr)
    quote
        local ts = @testset NoThrowTestSet begin
            $(esc(expr))
        end
        @test  any(t -> t isa Test.Fail,  ts)
        @test !any(t -> t isa Test.Error, ts)
    end
end
