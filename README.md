# IntervalSets.jl
Interval Sets for Julia

[![Build Status](https://travis-ci.org/JuliaMath/IntervalSets.jl.svg?branch=master)](https://travis-ci.org/JuliaMath/IntervalSets.jl)

[![Coverage Status](https://coveralls.io/repos/github/JuliaMath/IntervalSets.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaMath/IntervalSets.jl?branch=master)

This package represents intervals of an ordered set. For an interval
spanning from `a` to `b`, all values `x` that lie between `a` and `b`
are defined as being members of the interval.

Currently this package defines one concrete type, `ClosedInterval`.
These define the closed set spanning from `a` to `b`, meaning the
interval is defined as the set `{x}` satisfying `a ≤ x ≤ b`. This is
sometimes written `[a,b]` (mathematics syntax, not Julia syntax) or
`a..b`.

## Usage

You can construct `ClosedInterval`s in a variety of ways:

```julia
julia> using IntervalSets

julia> ClosedInterval{Float64}(1,3)
1.0..3.0

julia> 0.5..2.5
0.5..2.5

julia> 1.5±1
0.5..2.5
```

The `±` operator may be typed as `\pm<TAB>` (using Julia's LaTeX
syntax tab-completion).

Intervals also support the expected set operations:

```julia
julia> 1.75 ∈ 1.5±1  # \in<TAB>; can also use `in`
true

julia> 0 ∈ 1.5±1
false

julia> intersect(1..5, 3..7)   # can also use `a ∩ b`, where the symbol is \cap<TAB>
3..5

julia> isempty(intersect(1..5, 10..11))
true

julia> (0.25..5) ∪ (3..7.4)    # \cup<TAB>; can also use union()
0.25..7.4
```

When computing the union, the result must also be an interval:
```julia
julia> (0.25..5) ∪ (6..7.4)
------ ArgumentError ------------------- Stacktrace (most recent call last)

 [1] — union(::IntervalSets.ClosedInterval{Float64}, ::IntervalSets.ClosedInterval{Float64}) at closed.jl:34

ArgumentError: Cannot construct union of disjoint sets.
```
