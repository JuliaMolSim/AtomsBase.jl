# Testing against the AtomsBase interface

The `AtomsBaseTesting` package provides a few utility functions to test
downstream packages for having properly implemented the `AtomsBase` interface.
The tests are probably not complete, but they should be a good start ...
and as always PRs are welcome.

Two functions are provided, namely `make_test_system` to generate standard
`FlexibleSystem` test systems and `test_approx_eq` for testing approximate
equality between `AtomsBase` systems (of not necessarily the same type).
The basic idea of the functions is to use `make_test_system` to obtain a
test system, construct an identical system in a downstream library and then use
`test_approx_eq` to check they are actually equal.

For usage examples see the tests of [ExtXYZ](https://github.com/libAtoms/ExtXYZ.jl/blob/master/test/atomsbase.jl),
[AtomsIO](https://github.com/mfherbst/AtomsIO.jl/blob/master/test/xsf.jl),
[Chemfiles](https://github.com/chemfiles/Chemfiles.jl/blob/master/src/atomsbase.jl)
and [ASEconnect](https://github.com/mfherbst/ASEconvert.jl/blob/master/test/runtests.jl).
