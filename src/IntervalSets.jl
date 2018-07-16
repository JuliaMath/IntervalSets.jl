__precompile__()

module IntervalSets

using Base: @pure
import Base: eltype, convert, show, in, length, isempty, isequal, isless, issubset, ==, hash,
             union, intersect, minimum, maximum, extrema, range, ⊇

using Compat
using Compat.Dates

export AbstractInterval, ClosedInterval, ⊇, .., ±, ordered, width

abstract type AbstractInterval{T} end

include("closed.jl")

eltype(::Type{AbstractInterval{T}}) where {T} = T
@pure eltype(::Type{I}) where {I<:AbstractInterval} = eltype(supertype(I))

convert(::Type{I}, i::I) where {I<:AbstractInterval} = i
function convert(::Type{I}, i::AbstractInterval) where I<:AbstractInterval
    T = eltype(I)
    I(convert(T, i.left), convert(T, i.right))
end
function convert(::Type{I}, r::AbstractRange) where I<:AbstractInterval
    T = eltype(I)
    I(convert(T, minimum(r)), convert(T, maximum(r)))
end

ordered(a::T, b::T) where {T} = ifelse(a < b, (a, b), (b, a))
ordered(a, b) = ordered(promote(a, b)...)

checked_conversion(::Type{T}, a, b) where {T} = _checked_conversion(T, convert(T, a), convert(T, b))
_checked_conversion(::Type{T}, a::T, b::T) where {T} = a, b
_checked_conversion(::Type{Any}, a, b) = throw(ArgumentError("$a and $b promoted to type Any"))
_checked_conversion(::Type{T}, a, b) where {T} = throw(ArgumentError("$a and $b are not both of type $T"))

end # module
