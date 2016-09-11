__precompile__()

module IntervalSets

# package code goes here

import Base: show, in, length, isempty, isequal, issubset, ==, union, intersect

export ClosedInterval, ⊇, .., ±, ordered

include("closed.jl")

ordered{T}(a::T, b::T) = ifelse(a < b, (a, b), (b, a))
ordered(a, b) = ordered(promote(a, b)...)

checked_conversion{T}(::Type{T}, a, b) = _checked_conversion(T, convert(T, a), convert(T, b))
_checked_conversion{T}(::Type{T}, a::T, b::T) = a, b
_checked_conversion{T}(::Type{T}, a, b) = throw(ArgumentError("$a and $b are not both of type $T"))

end # module
