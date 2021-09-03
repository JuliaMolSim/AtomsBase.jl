using AtomsBase
using Documenter

DocMeta.setdocmeta!(AtomsBase, :DocTestSetup, :(using AtomsBase); recursive=true)

makedocs(;
    modules=[AtomsBase],
    authors="JuliaMolSim community",
    repo="https://github.com/mfherbst/AtomsBase.jl/blob/{commit}{path}#{line}",
    sitename="AtomsBase.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mfherbst.github.io/AtomsBase.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mfherbst/AtomsBase.jl",
    devbranch="master",
)
