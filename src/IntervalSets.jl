__precompile__()

module IntervalSets

# package code goes here

import Base: show, in, length, isempty, isequal, issubset, ==, union, intersect

export ClosedInterval, ⊇, .., ±, ordered

include("closed.jl")

ordered{T}(a::T, b::T) = ifelse(a < b, (a, b), (b, a))
ordered(a, b) = ordered(promote(a, b)...)

end # module
