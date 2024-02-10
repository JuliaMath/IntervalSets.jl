# IntervalSets.jl

A Julia package implementing [interval sets](https://en.wikipedia.org/wiki/Interval_(mathematics)).

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaMath.github.io/IntervalSets.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaMath.github.io/IntervalSets.jl/dev)
[![Build Status](https://github.com/JuliaMath/IntervalSets.jl/workflows/CI/badge.svg)](https://github.com/JuliaMath/IntervalSets.jl/actions)
[![Coverage](https://codecov.io/gh/JuliaMath/IntervalSets.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaMath/IntervalSets.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

!!! note "Documentation"
    The documentation is still work in progress.
    For more information, see also
    * [README in the repository](https://github.com/JuliaMath/IntervalSets.jl)
    * [Tests in the repository](https://github.com/JuliaMath/IntervalSets.jl/tree/master/test)
    Feel free to [open pull requests](https://github.com/JuliaMath/IntervalSets.jl/pulls) and improve this document!

## Installation
```
pkg> add IntervalSets
```

## Quick start

```@repl
using IntervalSets
i1 = 1.0 .. 3.0
i2 = OpenInterval(0..4)
i1 ⊆ i2
i2 ⊆ i1
```

Currently this package defines one concrete type, [`Interval`](@ref).
These define the set spanning from `a` to `b`, meaning the interval is defined as the set ``\{x \ | \ a ≤ x ≤ b\}``.
This is sometimes written ``[a,b]`` (mathematics syntax, not Julia syntax) or ``a..b``.

Optionally, `Interval{L,R}` can represent open and half-open intervals.
The type parameters `L` and `R` correspond to the left and right endpoint respectively.
The notation [`ClosedInterval`](@ref) is short for `Interval{:closed,:closed}`,
while [`OpenInterval`](@ref) is short for `Interval{:open,:open}`.
For example, the interval `Interval{:open,:closed}` corresponds to the set ``(a,b] = \{x \ | \ a < x ≤ b\}``.

## More examples

```@setup more
using IntervalSets
```

### Constructors
```@repl more
ClosedInterval{Float64}(1,3)
OpenInterval{Float64}(1,3)
Interval{:open, :closed}(1,3)
OpenInterval(0.5..2.5)  # construct `OpenInterval` from `ClosedInterval`
```

The [`±`](@ref) operator and [`..`](@ref) creates [`ClosedInterval`](@ref) instance.

```@repl more
0.5..2.5
1.5 ± 1  # \pm<TAB>
```

There is also a useful string macro [`@iv_str`](@ref) to define an interval with mathematical notations such as ``(a,b]``.

```@repl more
iv"[1,2]"
iv"[1,2)"
iv"(1,2]"
iv"(1,2)"
```

### Set operations

```@repl more
1.75 ∈ 1.5±1  # \in<TAB>; can also use `in`
0 ∈ 1.5±1
1 ∈ OpenInterval(0..1)
intersect(1..5, 3..7)   # can also use `a ∩ b`, where the symbol is \cap<TAB>
isempty(intersect(1..5, 10..11))
(0.25..5) ∪ (3..7.4)  # \cup<TAB>; can also use `union()`
isclosedset(0.5..2.0)
isopenset(OpenInterval(0.5..2.5))
isleftopen(2..3)
(0.25..5) ∪ (6..7.4)  # union of interval must be an interval
```

### Importing the `..` operator

To import the [`..`](@ref) operator, use `import IntervalSets: (..)`.
The parantheses are necessary to avoid parsing issues.

```@repl
import IntervalSets: (..)
import IntervalSets.(..)  # This is also okay
```
