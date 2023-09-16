using AtomsBase
using Documenter

DocMeta.setdocmeta!(AtomsBase, :DocTestSetup, :(using AtomsBase); recursive=true)

makedocs(;
    modules=[AtomsBase],
    authors="JuliaMolSim community",
    repo="https://github.com/JuliaMolSim/AtomsBase.jl/blob/{commit}{path}#{line}",
    sitename="AtomsBase.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://juliamolsim.github.io/AtomsBase.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "tutorial.md",
        "overview.md",
        "testing.md",
        "apireference.md"
    ],
    checkdocs=:exports,
)

deploydocs(;
    repo="github.com/JuliaMolSim/AtomsBase.jl",
    devbranch="master",
)
