
# this set of tests is intended to confirm that docstrings throughout the 
# codebase actually run. Currently, this is just a rough draft that includes 
# specific doc strings that have been reported to fail. There should be a more 
# natural and automated way to test this. 

using Unitful
using UnitfulAtomic
using AtomsBase
using Test 

## 
# atomic_system docstring

try 
   bounding_box = [[10.0, 0.0, 0.0], [0.0, 10.0, 0.0], [0.0, 0.0, 10.0]]u"Å"
   pbcs = (true, true, false)
   hydrogen = atomic_system([:H => [0, 0, 1.]u"bohr",
                                 :H => [0, 0, 3.]u"bohr"],
                                  bounding_box, pbcs)
   @test true
catch 
   @error("atomic_system docstring failed to run")
   @test false 
end


##
# isolated_system docstring

try 
   isolated_system([:H => [0, 0, 1.]u"bohr", :H => [0, 0, 3.]u"bohr"])
   @test true
catch
   @error("isolated_system docstring failed to run")
   @test false 
end

##
# periodic_system docstring 1 

try 
   bounding_box = ([10.0, 0.0, 0.0]u"Å", [0.0, 10.0, 0.0]u"Å", [0.0, 0.0, 10.0]u"Å")
   hydrogen = periodic_system([:H => [0, 0, 1.]u"bohr",
                                      :H => [0, 0, 3.]u"bohr"],
                                     bounding_box)
   @test true 
catch e 
   @error("periodic_system docstring 1 failed to run")
   @test false 
end 

##
# periodic

try 
   box = 10.26 / 2 * [[0, 0, 1], [1, 0, 1], [1, 1, 0]]u"bohr"
   silicon = periodic_system([:Si =>  ones(3)/8,
                                     :Si => -ones(3)/8],
                                    box, fractional=true)
   @test true 
catch e
   @error("periodic_system docstring 2 failed to run")
   @test false 
end
