__precompile__()

module IntervalSets

# package code goes here

using Base: @pure
import Base: eltype, convert, show, in, length, isempty, isequal, issubset, ==, hash, union, intersect, minimum, maximum

export AbstractInterval, ClosedInterval, ⊇, .., ±, ordered, width

abstract AbstractInterval{T}

include("closed.jl")

eltype{T}(::Type{AbstractInterval{T}}) = T
@pure eltype{I<:AbstractInterval}(::Type{I}) = eltype(supertype(I))

convert{I<:AbstractInterval}(::Type{I}, i::I) = i
function convert{I<:AbstractInterval}(::Type{I}, i::AbstractInterval)
    T = eltype(I)
    I(convert(T, i.left), convert(T, i.right))
end

ordered{T}(a::T, b::T) = ifelse(a < b, (a, b), (b, a))
ordered(a, b) = ordered(promote(a, b)...)

checked_conversion{T}(::Type{T}, a, b) = _checked_conversion(T, convert(T, a), convert(T, b))
_checked_conversion{T}(::Type{T}, a::T, b::T) = a, b
_checked_conversion{T}(::Type{T}, a, b) = throw(ArgumentError("$a and $b are not both of type $T"))

end # module
