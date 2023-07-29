using IntervalSets
using Documenter

DocMeta.setdocmeta!(IntervalSets, :DocTestSetup, :(using IntervalSets); recursive=true)

makedocs(;
    modules=[IntervalSets],
    repo="https://github.com/JuliaMath/IntervalSets.jl/blob/{commit}{path}#{line}",
    sitename="IntervalSets.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaMath.github.io/IntervalSets.jl",
        assets = ["assets/custom.css", "assets/favicon.ico"],
    ),
    pages=[
        "Home" => "index.md",
        "APIs" => "api.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaMath/IntervalSets.jl", devbranch="master",
)
