using AtomsBase
using Documenter

DocMeta.setdocmeta!(AtomsBase, :DocTestSetup, :(using AtomsBase); recursive=true)

makedocs(;
    modules=[AtomsBase],
    authors="JuliaMolSim community",
    sitename="AtomsBase.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://juliamolsim.github.io/AtomsBase.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Interface" => "interface.md", 
        "Utilities" => "utilities.md", 
        "Implementations" => "implementations.md",
        "Tutorial" => "tutorial.md",
        "Reference" => "apireference.md"
    ],
    checkdocs=:exports,
)

deploydocs(;
    repo="github.com/JuliaMolSim/AtomsBase.jl",
    devbranch="master",
)
