__precompile__()

module IntervalSets

using Base: @pure
import Base: eltype, convert, show, in, length, isempty, isequal, issubset, ==, hash,
             union, intersect, minimum, maximum, extrema, range, ⊇, mean, median

using Compat
using Compat.Dates

export AbstractInterval, ClosedInterval, ⊇, .., ±, ordered, width, leftendpoint, rightendpoint

abstract type AbstractInfiniteSet{T} end
abstract type AbstractInterval{T} <: AbstractInfiniteSet{T} end


"The left endpoint of the interval."
leftendpoint(d::AbstractInterval) = d.left

"The right endpoint of the interval."
rightendpoint(d::AbstractInterval) = d.right

"A tuple containing the left and right endpoints of the interval."
endpoints(d::AbstractInterval) = (leftendpoint(d), rightendpoint(d))

"Is the interval closed at the left endpoint?"
function isleftclosed end

"Is the interval closed at the right endpoint?"
function isrightclosed end



# open_left and open_right are implemented in terms of closed_* above, so those
# are the only ones that should be implemented for specific intervals
"Is the interval open at the left endpoint?"
isleftopen(d::AbstractInterval) = !isleftclosed(d)

"Is the interval open at the right endpoint?"
isrightopen(d::AbstractInterval) = !isrightclosed(d)

# Only closed if closed at both endpoints, and similar for open
isclosed(d::AbstractInterval) = isleftclosed(d) && isrightclosed(d)
isopen(d::AbstractInterval) = isleftopen(d) && isrightopen(d)

function infimum(d::AbstractInterval{T}) where T
    a = leftendpoint(d)
    b = rightendpoint(d)
    a > b && throw(ArgumentError("Infimum not defined for empty intervals"))
    a
end

function supremum(d::AbstractInterval{T}) where T
    a = leftendpoint(d)
    b = rightendpoint(d)
    a > b && throw(ArgumentError("Supremum not defined for empty intervals"))
    b
end

mean(d::AbstractInterval) = one(eltype(d))/2 * (leftendpoint(d) + rightendpoint(d))
median(d::AbstractInterval) = mean(d)



include("interval.jl")

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
