module IntervalSets

using Base: @pure
import Base: eltype, convert, show, in, length, isempty, isequal, isapprox, issubset, ==, hash,
             union, intersect, minimum, maximum, extrema, range, clamp, mod, float, ⊇, ⊊, ⊋,
             UnitRange

export AbstractInterval, Interval, OpenInterval, ClosedInterval, @iv_str,
            ⊇, .., ±, ordered, width, leftendpoint, rightendpoint, endpoints,
            isopenset, isclosedset, isleftclosed, isrightclosed,
            isleftopen, isrightopen, closedendpoints,
            infimum, supremum,
            searchsorted_interval

"""
A subtype of `Domain{T}` represents a subset of type `T`, that provides `in`.
"""
abstract type Domain{T} end

Base.IteratorSize(::Type{<:Domain}) = Base.SizeUnknown()
Base.isdisjoint(a::Domain, b::Domain) = isempty(a ∩ b)

"""
A subtype of `AbstractInterval{T}` represents an interval subset of type `T`, that provides
`endpoints`, `closedendpoints`.
"""
abstract type AbstractInterval{T} <: Domain{T} end

"""
    endpoints(d::AI) where AI<:AbstractInterval

A tuple containing the left and right endpoints of the interval.

# Examples
```jldoctest
julia> endpoints(iv"[1,2]")
(1, 2)

julia> endpoints(iv"(2,1)")
(2, 1)
```
"""
endpoints(d::AI) where AI<:AbstractInterval = error("Override endpoints(::$(AI))")

"""
    leftendpoint(d::AbstractInterval)

The left endpoint of the interval.

# Examples
```jldoctest
julia> leftendpoint(iv"[1,2]")
1

julia> leftendpoint(iv"(2,1)")
2
```
"""
leftendpoint(d::AbstractInterval) = endpoints(d)[1]

"""
    rightendpoint(d::AbstractInterval)

The right endpoint of the interval.

# Examples
```jldoctest
julia> rightendpoint(iv"[1,2]")
2

julia> rightendpoint(iv"(2,1)")
1
```
"""
rightendpoint(d::AbstractInterval) = endpoints(d)[2]

"""
    closedendpoints(d::AI) where AI<:AbstractInterval

A tuple of `Bool`'s encoding whether the left/right endpoints are closed.

# Examples
```jldoctest
julia> closedendpoints(iv"[1,2]")
(true, true)

julia> closedendpoints(iv"(1,2]")
(false, true)

julia> closedendpoints(iv"[2,1)")
(true, false)

julia> closedendpoints(iv"(2,1)")
(false, false)
```
"""
closedendpoints(d::AI) where AI<:AbstractInterval = error("Override closedendpoints(::$(AI))")

"""
    isleftclosed(d::AbstractInterval)

Is the interval closed at the left endpoint?

# Examples
```jldoctest
julia> isleftclosed(iv"[1,2]")
true

julia> isleftclosed(iv"(2,1)")
false
```
"""
isleftclosed(d::AbstractInterval) = closedendpoints(d)[1]

"""
    isrightclosed(d::AbstractInterval)

Is the interval closed at the right endpoint?

# Examples
```jldoctest
julia> isrightclosed(iv"[1,2]")
true

julia> isrightclosed(iv"(2,1)")
false
```
"""
isrightclosed(d::AbstractInterval) = closedendpoints(d)[2]

# open_left and open_right are implemented in terms of closed_* above, so those
# are the only ones that should be implemented for specific intervals
"""
    isleftopen(d::AbstractInterval)

Is the interval open at the left endpoint?

# Examples
```jldoctest
julia> isleftopen(iv"[1,2]")
false

julia> isleftopen(iv"(2,1)")
true
```
"""
isleftopen(d::AbstractInterval) = !isleftclosed(d)

"""
    isrightopen(d::AbstractInterval)

Is the interval open at the right endpoint?

# Examples
```jldoctest
julia> isrightopen(iv"[1,2]")
false

julia> isrightopen(iv"(2,1)")
true
```
"""
isrightopen(d::AbstractInterval) = !isrightclosed(d)

"""
    isclosedset(d::AbstractInterval)

Is the interval closed set?

# Examples
```jldoctest
julia> isclosedset(iv"[1,2]")
true

julia> isclosedset(iv"(1,2]")
false

julia> isclosedset(iv"[1,2)")
false

julia> isclosedset(iv"(1,2)")
false
```
"""
isclosedset(d::AbstractInterval) = isleftclosed(d) && isrightclosed(d)

"""
    isopenset(d::AbstractInterval)

Is the interval open set?

# Examples
```jldoctest
julia> isopenset(iv"[1,2]")
false

julia> isopenset(iv"(1,2]")
false

julia> isopenset(iv"[1,2)")
false

julia> isopenset(iv"(1,2)")
true
```
"""
isopenset(d::AbstractInterval) = isleftopen(d) && isrightopen(d)

eltype(::Type{AbstractInterval{T}}) where {T} = T
@pure eltype(::Type{I}) where {I<:AbstractInterval} = eltype(supertype(I))

convert(::Type{AbstractInterval}, i::AbstractInterval) = i
convert(::Type{AbstractInterval{T}}, i::AbstractInterval{T}) where T = i


ordered(a::T, b::T) where {T} = ifelse(a < b, (a, b), (b, a))
ordered(a, b) = ordered(promote(a, b)...)

checked_conversion(::Type{T}, a, b) where {T} = _checked_conversion(T, convert(T, a), convert(T, b))
_checked_conversion(::Type{T}, a::T, b::T) where {T} = a, b
_checked_conversion(::Type{Any}, a, b) = throw(ArgumentError("$a and $b promoted to type Any"))
_checked_conversion(::Type{T}, a, b) where {T} = throw(ArgumentError("$a and $b are not both of type $T"))

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

mean(d::AbstractInterval) = (leftendpoint(d) + rightendpoint(d))/2

"""
    w = width(iv)

Calculate the width (max-min) of interval `iv`. Note that for integers
`l` and `r`, `width(l..r) = length(l:r) - 1`.

# Examples
```jldoctest
julia> width(2..7)
5

julia> length(2:7)
6
```
"""
function width(A::AbstractInterval)
    _width = rightendpoint(A) - leftendpoint(A)
    max(zero(_width), _width)   # this works when T is a Date
end

"""
A subtype of `TypedEndpointsInterval{L,R,T}` where `L` and `R` are `:open` or `:closed`,
that represents an interval subset of type `T`, and provides `endpoints`.
"""
abstract type TypedEndpointsInterval{L,R,T} <: AbstractInterval{T} end

closedendpoints(d::TypedEndpointsInterval{:closed,:closed}) = (true,true)
closedendpoints(d::TypedEndpointsInterval{:closed,:open}) = (true,false)
closedendpoints(d::TypedEndpointsInterval{:open,:closed}) = (false,true)
closedendpoints(d::TypedEndpointsInterval{:open,:open}) = (false,false)

# We dispatch to _in to avoid ambiguities if packages define in(v::CustomType, I::TypedEndpointsInterval)
in(v, I::TypedEndpointsInterval) = _in(v, I)
_in(v, I::TypedEndpointsInterval{:closed,:closed}) = leftendpoint(I) ≤ v ≤ rightendpoint(I)
_in(v, I::TypedEndpointsInterval{:open,:open}) = leftendpoint(I) < v < rightendpoint(I)
_in(v, I::TypedEndpointsInterval{:closed,:open}) = leftendpoint(I) ≤ v < rightendpoint(I)
_in(v, I::TypedEndpointsInterval{:open,:closed}) = leftendpoint(I) < v ≤ rightendpoint(I)

_in(v::Complex, I::TypedEndpointsInterval{:closed,:closed}) = isreal(v) && in(real(v), I)
_in(v::Complex, I::TypedEndpointsInterval{:open,:open}) = isreal(v) && in(real(v), I)
_in(v::Complex, I::TypedEndpointsInterval{:closed,:open}) = isreal(v) && in(real(v), I)
_in(v::Complex, I::TypedEndpointsInterval{:open,:closed}) = isreal(v) && in(real(v), I)

_in(::Missing, I::TypedEndpointsInterval{:closed,:closed}) = !isempty(I) && missing
_in(::Missing, I::TypedEndpointsInterval{:open,:open}) = !isempty(I) && missing
_in(::Missing, I::TypedEndpointsInterval{:closed,:open}) = !isempty(I) && missing
_in(::Missing, I::TypedEndpointsInterval{:open,:closed}) = !isempty(I) && missing

isempty(A::TypedEndpointsInterval{:closed,:closed}) = leftendpoint(A) > rightendpoint(A)
isempty(A::TypedEndpointsInterval) = leftendpoint(A) ≥ rightendpoint(A)

isequal(A::TypedEndpointsInterval{L,R}, B::TypedEndpointsInterval{L,R}) where {L,R} = (isequal(leftendpoint(A), leftendpoint(B)) & isequal(rightendpoint(A), rightendpoint(B))) | (isempty(A) & isempty(B))
isequal(A::TypedEndpointsInterval, B::TypedEndpointsInterval) = isempty(A) & isempty(B)

==(A::TypedEndpointsInterval{L,R}, B::TypedEndpointsInterval{L,R}) where {L,R} = (leftendpoint(A) == leftendpoint(B) && rightendpoint(A) == rightendpoint(B)) || (isempty(A) && isempty(B))
==(A::TypedEndpointsInterval, B::TypedEndpointsInterval) = isempty(A) && isempty(B)

function isapprox(A::AbstractInterval, B::AbstractInterval; atol=0, rtol=Base.rtoldefault(eltype(A), eltype(B), atol), kwargs...)
    closedendpoints(A) != closedendpoints(B) && error("Comparing intervals with different closedness is not defined")
    isempty(A) != isempty(B) && return false
    isempty(A) && isempty(B) && return true
    maxabs = max(maximum(abs, endpoints(A)), maximum(abs, endpoints(B)))
    let atol = max(atol, rtol * maxabs)
        isapprox(leftendpoint(A), leftendpoint(B); atol, rtol, kwargs...) && isapprox(rightendpoint(A), rightendpoint(B); atol, rtol, kwargs...)
    end
end

function issubset(A::TypedEndpointsInterval, B::TypedEndpointsInterval)
    Al, Ar = endpoints(A)
    Bl, Br = endpoints(B)
    return isempty(A) | ( (Bl ≤ Al) & (Ar ≤ Br) )
end
function issubset(A::TypedEndpointsInterval{:closed,R1} where R1, B::TypedEndpointsInterval{:open,R2} where R2)
    Al, Ar = endpoints(A)
    Bl, Br = endpoints(B)
    return isempty(A) | ( (Bl < Al) & (Ar ≤ Br) )
end
function issubset(A::TypedEndpointsInterval{L1,:closed} where L1, B::TypedEndpointsInterval{L2,:open} where L2)
    Al, Ar = endpoints(A)
    Bl, Br = endpoints(B)
    return isempty(A) | ( (Bl ≤ Al) & (Ar < Br) )
end
function issubset(A::TypedEndpointsInterval{:closed,:closed}, B::TypedEndpointsInterval{:open,:open})
    Al, Ar = endpoints(A)
    Bl, Br = endpoints(B)
    return isempty(A) | ( (Bl < Al) & (Ar < Br) )
end

⊊(A::AbstractInterval, B::AbstractInterval) = (A ≠ B) & (A ⊆ B)

const _interval_hash = UInt == UInt64 ? 0x1588c274e0a33ad4 : 0x1e3f7252

hash(I::TypedEndpointsInterval, h::UInt) = hash(leftendpoint(I), hash(rightendpoint(I), hash(_interval_hash, h)))

minimum(d::TypedEndpointsInterval{:closed}) = infimum(d)
minimum(d::TypedEndpointsInterval{:open}) = throw(ArgumentError("$d is open on the left. Use infimum."))
maximum(d::TypedEndpointsInterval{L,:closed}) where L = supremum(d)
maximum(d::TypedEndpointsInterval{L,:open}) where L = throw(ArgumentError("$d is open on the right. Use supremum."))

extrema(I::TypedEndpointsInterval) = (infimum(I), supremum(I))

# Open and closed at endpoints
isleftclosed(d::TypedEndpointsInterval{:closed}) = true
isleftclosed(d::TypedEndpointsInterval{:open}) = false
isrightclosed(d::TypedEndpointsInterval{L,:closed}) where {L} = true
isrightclosed(d::TypedEndpointsInterval{L,:open}) where {L} = false

# UnitRange construction
# The third is the one we want, but the first two are needed to resolve ambiguities
Base.Slice{T}(i::TypedEndpointsInterval{:closed,:closed,I}) where {T<:AbstractUnitRange,I<:Integer} =
    Base.Slice{T}(minimum(i):maximum(i))
Base.Slice(i::TypedEndpointsInterval{:closed,:closed,I}) where I<:Integer =
    Base.Slice(minimum(i):maximum(i))
function Base.OneTo{T}(i::TypedEndpointsInterval{:closed,:closed,I}) where {T<:Integer,I<:Integer}
    @noinline throwstart(i) = throw(ArgumentError("smallest element must be 1, got $(minimum(i))"))
    minimum(i) == 1 || throwstart(i)
    Base.OneTo{T}(maximum(i))
end
Base.OneTo(i::TypedEndpointsInterval{:closed,:closed,I}) where {I<:Integer} =
    Base.OneTo{I}(i)
Base.UnitRange{T}(i::TypedEndpointsInterval{:closed,:closed,I}) where {T<:Integer,I<:Integer} = UnitRange{T}(minimum(i), maximum(i))
Base.UnitRange(i::TypedEndpointsInterval{:closed,:closed,I}) where {I<:Integer} = UnitRange{I}(i)
range(i::TypedEndpointsInterval{:closed,:closed,I}) where {I<:Integer} = UnitRange{I}(i)

"""
    range(i::ClosedInterval; step, length)
    range(i::ClosedInterval, length::Integer)

Constructs a range of a specified step or length.

# Examples
```jldoctest
julia> range(1..2, 8)
1.0:0.14285714285714285:2.0

julia> range(1, 2, 8)
1.0:0.14285714285714285:2.0

julia> range(1..2, step=0.2)
1.0:0.2:2.0

julia> range(1, 2, step=0.2)
1.0:0.2:2.0
```
"""
range(i::TypedEndpointsInterval{:closed,:closed}; step=nothing, length=nothing) =
    range(leftendpoint(i); stop=rightendpoint(i), step=step, length=length)
range(i::TypedEndpointsInterval{:closed,:closed}, length::Integer) = range(i; length=length)

"""
    range(i::Interval{:closed,:open}; length)
    range(i::Interval{:closed,:open}, length::Integer)
    range(i::Interval{:open,:closed}; length)
    range(i::Interval{:open,:closed}, length::Integer)

Constructs a range of a specified length with `step=width(i)/length`.

# Examples
```jldoctest
julia> range(iv"[1, 2)", 7)  # Does not contain right endpoint
1.0:0.14285714285714285:1.8571428571428572

julia> range(iv"(1, 2]", 7)  # Does not contain left endpoint
1.1428571428571428:0.14285714285714285:2.0

julia> range(1, 2, 8)
1.0:0.14285714285714285:2.0
```
"""
range(i::TypedEndpointsInterval{:closed,:open}; length::Integer) =
    range(leftendpoint(i); step=width(i)/length, length=length)
range(i::TypedEndpointsInterval{:closed,:open}, length::Integer) = range(i; length=length)

range(i::TypedEndpointsInterval{:open,:closed}; length::Integer) =
    range(; stop = rightendpoint(i), step = width(i)/length, length)
range(i::TypedEndpointsInterval{:open,:closed}, length::Integer) = range(i; length)

"""
    range(i::OpenInterval; length)
    range(i::OpenInterval, length::Integer)

Constructs a range of a specified length with `step = width(i) / (length + 1)`.

# Examples
```jldoctest
julia> range(iv"(1, 4)", 5)  # Does not contain the endpoints
1.5:0.5:3.5

julia> range(1, 4, 7)
1.0:0.5:4.0
```
"""
function range(i::TypedEndpointsInterval{:open,:open}; length::Integer)
    step = width(i) / (length + 1)
    range(leftendpoint(i) + step; step, length)
end

range(i::TypedEndpointsInterval{:open,:open}, length::Integer) = range(i; length)

"""
    clamp(t, i::ClosedInterval)

Clamp the scalar `t` such that the result is in the interval `i`.

# Examples
```jldoctest
julia> clamp(1.2, 1..2)
1.2

julia> clamp(2.2, 1..2)
2.0
```
"""
clamp(t, i::TypedEndpointsInterval{:closed,:closed}) =
    clamp(t, leftendpoint(i), rightendpoint(i))

"""
    mod(x, i::AbstractInterval)

Find `y` in the `i` interval such that ``x ≡ y \\pmod w``, where `w = width(i)`.

# Examples

```jldoctest
julia> I = 2.5..4.5;

julia> mod(3.0, I)
3.0

julia> mod(5.0, I)
3.0

julia> mod(2.5, I)
2.5

julia> mod(4.5, I)  # (a in I) does not imply (a == mod(a, I)) for closed intervals
2.5

julia> mod(4.5, Interval{:open, :closed}(2.5, 4.5))
4.5
```
"""
mod(x, i::TypedEndpointsInterval{:closed,:closed}) = mod(x - leftendpoint(i), width(i)) + leftendpoint(i)

function mod(x, i::AbstractInterval)
    res = mod(x - leftendpoint(i), width(i)) + leftendpoint(i)
    if res == rightendpoint(i) && isrightopen(i)
        isleftclosed(i) && return oftype(res, leftendpoint(i))
    elseif res == leftendpoint(i) && isleftopen(i)
        isrightclosed(i) && return oftype(res, rightendpoint(i))
    else
        return res
    end
    throw(DomainError(x, "mod() result is an endpoint of the open interval $i"))
end

include("interval.jl")
include("findall.jl")

if !isdefined(Base, :get_extension)
    include("../ext/IntervalSetsStatisticsExt.jl")
    include("../ext/IntervalSetsRandomExt.jl")
    include("../ext/IntervalSetsRecipesBaseExt.jl")
end

end # module
