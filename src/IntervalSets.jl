__precompile__()

module IntervalSets

# package code goes here

using Base: @pure
import Base: eltype, convert, show, in, length, isempty, isequal, issubset, ==, hash, union, intersect, minimum, maximum, extrema, range
if isdefined(Main, :⊇)
    import Base: ⊇
end

using Compat

export AbstractInterval, ClosedInterval, ⊇, .., ±, ordered, width

@compat abstract type AbstractInterval{T} end

include("closed.jl")

eltype{T}(::Type{AbstractInterval{T}}) = T
@pure eltype{I<:AbstractInterval}(::Type{I}) = eltype(supertype(I))

convert{I<:AbstractInterval}(::Type{I}, i::I) = i
function convert{I<:AbstractInterval}(::Type{I}, i::AbstractInterval)
    T = eltype(I)
    I(convert(T, i.left), convert(T, i.right))
end
function convert{I<:AbstractInterval}(::Type{I}, r::Range)
    T = eltype(I)
    I(convert(T, minimum(r)), convert(T, maximum(r)))
end

ordered{T}(a::T, b::T) = ifelse(a < b, (a, b), (b, a))
ordered(a, b) = ordered(promote(a, b)...)

checked_conversion{T}(::Type{T}, a, b) = _checked_conversion(T, convert(T, a), convert(T, b))
_checked_conversion{T}(::Type{T}, a::T, b::T) = a, b
_checked_conversion(::Type{Any}, a, b) = throw(ArgumentError("$a and $b promoted to type Any"))
_checked_conversion{T}(::Type{T}, a, b) = throw(ArgumentError("$a and $b are not both of type $T"))

end # module
