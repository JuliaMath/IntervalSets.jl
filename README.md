# IntervalSets.jl
Interval Sets for Julia

[![Build Status](https://github.com/JuliaMath/IntervalSets.jl/workflows/CI/badge.svg)](https://github.com/JuliaMath/IntervalSets.jl/actions)
[![Coverage](https://codecov.io/gh/JuliaMath/IntervalSets.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaMath/IntervalSets.jl)

This package represents intervals of an ordered set. For an interval
spanning from `a` to `b`, all values `x` that lie between `a` and `b`
are defined as being members of the interval.

This package is intended to implement a "minimal" foundation for
intervals upon which other packages might build. In particular, we
*encourage* [type-piracy](https://docs.julialang.org/en/v1/manual/style-guide/#Avoid-type-piracy)
for the reason that only one interval package can
unambiguously define the `..` and `±` operators (see below).

Currently this package defines one concrete type, `Interval`.
These define the set spanning from `a` to `b`, meaning the
interval is defined as the set `{x}` satisfying `a ≤ x ≤ b`. This is
sometimes written `[a,b]` (mathematics syntax, not Julia syntax) or
`a..b`.

Optionally, `Interval{L,R}` can represent open and half-open intervals. The type
parameters `L` and `R` correspond to the left and right endpoint respectively.
The notation `ClosedInterval` is short for `Interval{:closed,:closed}`, while `OpenInterval` is short for `Interval{:open,:open}`. For example, the interval `Interval{:open,:closed}` corresponds to the set `{x}` satisfying `a < x ≤ b`.

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

Similarly, you can construct `OpenInterval`s and `Interval{:open,:closed}`s, and `Interval{:closed,:open}`:
```julia
julia> OpenInterval{Float64}(1,3)
1.0..3.0 (open)

julia> OpenInterval(0.5..2.5)
0.5..2.5 (open)

julia> Interval{:open,:closed}(1,3)
1..3 (open–closed)
```

The `±` operator may be typed as `\pm<TAB>` (using Julia's LaTeX
syntax tab-completion).

Intervals also support the expected set operations:

```julia
julia> 1.75 ∈ 1.5±1  # \in<TAB>; can also use `in`
true

julia> 0 ∈ 1.5±1
false

julia> 1 ∈ OpenInterval(0..1)
false

julia> intersect(1..5, 3..7)   # can also use `a ∩ b`, where the symbol is \cap<TAB>
3..5

julia> isempty(intersect(1..5, 10..11))
true

julia> (0.25..5) ∪ (3..7.4)    # \cup<TAB>; can also use union()
0.25..7.4

julia> isclosedset(0.5..2.0)
true

julia> isopenset(OpenInterval(0.5..2.5))
true

julia> isleftopen(2..3)
false
```

When computing the union, the result must also be an interval:
```julia
julia> (0.25..5) ∪ (6..7.4)
------ ArgumentError ------------------- Stacktrace (most recent call last)

 [1] — union(::IntervalSets.ClosedInterval{Float64}, ::IntervalSets.ClosedInterval{Float64}) at closed.jl:34

ArgumentError: Cannot construct union of disjoint sets.
```
