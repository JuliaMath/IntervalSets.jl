# IntervalSets.jl
Interval Sets for Julia

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaMath.github.io/IntervalSets.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaMath.github.io/IntervalSets.jl/dev)
[![Build Status](https://github.com/JuliaMath/IntervalSets.jl/workflows/CI/badge.svg)](https://github.com/JuliaMath/IntervalSets.jl/actions)
[![Coverage](https://codecov.io/gh/JuliaMath/IntervalSets.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaMath/IntervalSets.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

## Quick start

```julia
julia> using IntervalSets

julia> i1 = 1.0 .. 3.0
1.0 .. 3.0

julia> i2 = OpenInterval(0..4)
0 .. 4 (open)

julia> i1 ⊆ i2
true

julia> i2 ⊆ i1
false
```

Please refer to the [documentation](https://JuliaMath.github.io/IntervalSets.jl/stable) for comprehensive guides and examples.
