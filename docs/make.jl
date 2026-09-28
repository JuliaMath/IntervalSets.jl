using IntervalSets
using Documenter

# We need to set `ENV["GKSwstype"]` to suppress the warning on GitHub Actions.
# https://github.com/JuliaPlots/Plots.jl/issues/1076#issuecomment-327509819
ENV["GKSwstype"] = "100"

DocMeta.setdocmeta!(IntervalSets, :DocTestSetup, :(using IntervalSets); recursive=true)

makedocs(;
    modules=[IntervalSets],
    # Julia ≥ 1.13 shows empty ranges as, e.g., 4:3 (empty range). A filter only applies if it matches both the
    # expected and the evaluated output, so this also matches the empty string at the end
    doctestfilters=[r"( \(empty range\))?$"],
    repo="https://github.com/JuliaMath/IntervalSets.jl/blob/{commit}{path}#{line}",
    sitename="IntervalSets.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaMath.github.io/IntervalSets.jl",
        assets = ["assets/custom.css", "assets/favicon.ico"],
        repolink="https://github.com/JuliaMath/IntervalSets.jl",
    ),
    pages=[
        "Home" => "index.md",
        "APIs" => "api.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaMath/IntervalSets.jl", devbranch="master",
)
