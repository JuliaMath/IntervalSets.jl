"""
An `Interval{L,R}(left, right)` where L,R are :open or :closed
is an interval set containg `x` such that
1. `left ≤ x ≤ right` if `L == R == :closed`
2. `left < x ≤ right` if `L == :open` and `R == :closed`
3. `left ≤ x < right` if `L == :closed` and `R == :open`, or
4. `left < x < right` if `L == R == :open`
"""
struct Interval{L,R,T}  <: AbstractInterval{T}
    left::T
    right::T

    Interval{L,R,T}(l::T, r::T) where {L,R,T} = new{L,R,T}(l, r)
    Interval{L,R,T}(l, r) where {L,R,T} = ((a, b) = checked_conversion(T, l, r); new{L,R,T}(a, b))
    Interval{L,R,T}(i::AbstractInterval) where {L,R,T} = Interval{L,R,T}(endpoints(i)...)
end

"""
A `ClosedInterval(left, right)` is an interval set that includes both its upper and lower bounds. In
mathematical notation, the constructed range is `[left, right]`.
"""
const ClosedInterval{T} = Interval{:closed,:closed,T}

"""
An `OpenInterval(left, right)` is an interval set that includes both its upper and lower bounds. In
mathematical notation, the constructed range is `(left, right)`.
"""
const OpenInterval{T} = Interval{:open,:open,T}

Interval{L,R}(left, right) where {L,R} = Interval{L,R,promote_type(typeof(left), typeof(right))}(left,right)
Interval{L,R}(left::T, right::T) where {L,R,T} = Interval{L,R,T}(left, right)
Interval(left, right) = ClosedInterval(left, right)


# Interval(::AbstractInterval) allows open/closed intervals to be changed
Interval{L,R}(i::AbstractInterval) where {L,R} = Interval{L,R}(endpoints(i)...)
convert(::Type{Interval}, i::Interval) = i

function convert(::Type{II}, i::AbstractInterval) where II<:ClosedInterval
    isclosed(i) ||  throw(InexactError())
    II(i)
end
function convert(::Type{II}, i::AbstractInterval) where II<:OpenInterval
    isopen(i) ||  throw(InexactError())
    II(i)
end
function convert(::Type{II}, i::AbstractInterval) where II<:Interval{:open,:closed}
    (isleftopen(i) && isrightclosed(i)) ||  throw(InexactError())
    II(i)
end
function convert(::Type{II}, i::AbstractInterval) where II<:Interval{:closed,:open}
    (isleftclosed(i) && isrightopen(i)) ||  throw(InexactError())
    II(i)
end


for STyp in (:AbstractInfiniteSet, :AbstractInterval)
    @eval begin
        convert(::Type{$STyp{T}}, d::Interval{L,R,T}) where {L,R,T} = d
        convert(::Type{$STyp{T}}, d::Interval{L,R}) where {L,R,T} =
            Interval{L,R,T}(T(leftendpoint(d)), T(rightendpoint(d)))
    end
end



# the following is not typestable
function convert(::Type{Interval}, i::AbstractInterval)
    isopen(i) && return convert(OpenInterval, i)
    isclosed(i) && return convert(ClosedInterval, i)
    isleftopen(i) && return convert(Interval{:open,:closed}, i)
    return convert(Interval{:closed,:open}, i)
end


"""
    iv = l..r

Construct a ClosedInterval `iv` spanning the region from `l` to `r`.
"""
..(x, y) = ClosedInterval(x, y)

"""
    iv = center±halfwidth

Construct a ClosedInterval `iv` spanning the region from
`center - halfwidth` to `center + halfwidth`.
"""
±(x, y) = ClosedInterval(x - y, x + y)
±(x::CartesianIndex, y) = (xy = y * one(x); map(ClosedInterval, (x - xy).I, (x + xy).I))

show(io::IO, I::ClosedInterval) = print(io, I.left, "..", I.right)

in(v, I::ClosedInterval) = I.left ≤ v ≤ I.right
in(v, I::OpenInterval) = I.left < v < I.right
in(v, I::Interval{:closed,:open}) = I.left ≤ v < I.right
in(v, I::Interval{:open,:closed}) = I.left < v ≤ I.right
in(a::Interval, b::ClosedInterval) = (a.left ≥ b.left) & (a.right ≤ b.right)
in(a::OpenInterval, b::OpenInterval) = (a.left ≥ b.left) & (a.right ≤ b.right)
in(a::Interval{:closed,:open}, b::OpenInterval) = (a.left > b.left) & (a.right ≤ b.right)
in(a::Interval{:open,:closed}, b::OpenInterval) = (a.left ≥ b.left) & (a.right < b.right)
in(a::ClosedInterval, b::OpenInterval) = (a.left > b.left) & (a.right < b.right)
in(a::Interval{:closed}, b::Interval{:open,:closed}) = (a.left > b.left) & (a.right ≤ b.right)
in(a::Interval{:open}, b::Interval{:open,:closed}) = (a.left ≥ b.left) & (a.right ≤ b.right)
in(a::Interval{L,:closed}, b::Interval{:closed,:open}) where L = (a.left ≥ b.left) & (a.right < b.right)
in(a::Interval{L,:open}, b::Interval{:closed,:open}) where L = (a.left ≥ b.left) & (a.right ≤ b.right)


isempty(A::ClosedInterval) = A.left > A.right
isempty(A::Interval) = A.left ≥ A.right

isequal(A::Interval{L,R}, B::Interval{L,R}) where {L,R} = (isequal(A.left, B.left) & isequal(A.right, B.right)) | (isempty(A) & isempty(B))
isequal(A::Interval, B::Interval) = isempty(A) & isempty(B)

==(A::Interval{L,R}, B::Interval{L,R}) where {L,R} = (A.left == B.left && A.right == B.right) || (isempty(A) && isempty(B))
==(A::Interval, B::Interval) = isempty(A) && isempty(B)

const _interval_hash = UInt == UInt64 ? 0x1588c274e0a33ad4 : 0x1e3f7252

hash(I::Interval, h::UInt) = hash(I.left, hash(I.right, hash(_interval_hash, h)))

minimum(d::Interval{:closed}) = infimum(d)
minimum(d::Interval{:open}) = throw(ArgumentError("$d is open on the left. Use infimum."))
maximum(d::Interval{L,:closed}) where L = supremum(d)
maximum(d::Interval{L,:open}) where L = throw(ArgumentError("$d is open on the right. Use supremum."))

extrema(I::Interval) = (infimum(I), supremum(I))

# Open and closed at endpoints
isleftclosed(d::Interval{:closed}) = true
isleftclosed(d::Interval{:open}) = false
isrightclosed(d::Interval{L,:closed}) where {L} = true
isrightclosed(d::Interval{L,:open}) where {L} = false

# The following are not typestable for mixed endpoint types
_left_intersect_type(::Type{Val{:open}}, ::Type{Val{L2}}, a1, a2) where L2 = a1 < a2 ? (a2,L2) : (a1,:open)
_left_intersect_type(::Type{Val{:closed}}, ::Type{Val{L2}}, a1, a2) where L2 = a1 ≤ a2 ? (a2,L2) : (a1,:closed)
_right_intersect_type(::Type{Val{:open}}, ::Type{Val{R2}}, b1, b2) where R2 = b1 > b2 ? (b2,R2) : (b1,:open)
_right_intersect_type(::Type{Val{:closed}}, ::Type{Val{R2}}, b1, b2) where R2 = b1 ≥ b2 ? (b2,R2) : (b1,:closed)

function intersect(d1::Interval{L1,R1,T}, d2::Interval{L2,R2,T}) where {L1,R1,L2,R2,T}
    a1, b1 = endpoints(d1); a2, b2 = endpoints(d2)
    a,L = _left_intersect_type(Val{L1}, Val{L2}, a1, a2)
    b,R = _right_intersect_type(Val{R1}, Val{R2}, b1, b2)
    Interval{L,R}(a,b)
end

function intersect(d1::Interval{L,R,T}, d2::Interval{L,R,T}) where {L,R,T}
    a1, b1 = endpoints(d1); a2, b2 = endpoints(d2)
    Interval{L,R}(max(a1,a2),min(b1,b2))
end




union(d1::ClosedInterval, d2::ClosedInterval) = _closed_closed_union(d1,d2)
union(d1::Interval{:open,:closed}, d2::ClosedInterval) = _closed_closed_union(d1,d2)
union(d1::Interval{:closed,:open}, d2::ClosedInterval) = _closed_closed_union(d1,d2)
union(d1::ClosedInterval, d2::Interval{:open,:closed}) = _closed_closed_union(d1,d2)
union(d1::ClosedInterval, d2::Interval{:closed,:open}) = _closed_closed_union(d1,d2)
union(d1::Interval{:open,:closed}, d2::Interval{:open,:closed}) = _closed_closed_union(d1,d2)
union(d1::Interval{:closed,:open}, d2::Interval{:closed,:open}) = _closed_closed_union(d1,d2)
union(d1::ClosedInterval, d2::OpenInterval) = _closed_closed_union(d1,d2)
union(d1::OpenInterval, d2::ClosedInterval) = _closed_closed_union(d1,d2)


function _closed_closed_union(d1, d2)
    isempty(d1) && return d2
    isempty(d2) && return d1
    d1.left ≤ d2.left ≤ d1.right  || d1.left ≤ d2.right ≤ d1.right ||
        d2.left ≤ d1.left ≤ d2.right || d2.left ≤ d1.right ≤ d2.right ||
        throw(ArgumentError("Cannot construct union of disjoint sets."))
    _union(d1, d2)
end


function union(d1::OpenInterval, d2::OpenInterval)
    isempty(d1) && return d2
    isempty(d2) && return d1
    d1.left ≤ d2.left < d1.right  || d1.left < d2.right ≤ d1.right ||
        d2.left ≤ d1.left < d2.right  || d2.left < d1.right ≤ d2.right ||
        throw(ArgumentError("Cannot construct union of disjoint sets."))
    _union(d1, d2)
end

function union(d1::OpenInterval, d2::Interval{:open,:closed})
    isempty(d1) && return d2
    isempty(d2) && return d1
    d1.left ≤ d2.left < d1.right  || d1.left ≤ d2.right ≤ d1.right ||
        d2.left ≤ d1.left ≤ d2.right  || d2.left < d1.right ≤ d2.right ||
        throw(ArgumentError("Cannot construct union of disjoint sets."))
    _union(d1, d2)
end

function union(d1::OpenInterval, d2::Interval{:closed,:open})
    isempty(d1) && return d2
    isempty(d2) && return d1
    d1.left ≤ d2.left ≤ d1.right  || d1.left < d2.right ≤ d1.right ||
        d2.left ≤ d1.left < d2.right  || d2.left ≤ d1.right ≤ d2.right ||
        throw(ArgumentError("Cannot construct union of disjoint sets."))
    _union(d1, d2)
end

union(d1::Interval, d2::OpenInterval) = union(d2, d1)


function union(d1::Interval{:closed,:open}, d2::Interval{:open,:closed})
    isempty(d1) && return d2
    isempty(d2) && return d1
    d1.left ≤ d2.left < d1.right  || d1.left ≤ d2.right ≤ d1.right ||
        d2.left ≤ d1.left ≤ d2.right  || d2.left < d1.right ≤ d2.right ||
        throw(ArgumentError("Cannot construct union of disjoint sets."))
    _union(d1, d2)
end

union(d1::Interval{:open,:closed}, d2::Interval{:closed,:open}) = union(d2, d1)



# these assume overlap
function _union(A::Interval{L,R}, B::Interval{L,R}) where {L,R}
    left = min(A.left, B.left)
    right = max(A.right, B.right)
    Interval{L,R}(left, right)
end

# this is not typestable
function _union(A::Interval{L1,R1}, B::Interval{L2,R2}) where {L1,R1,L2,R2}
    if A.left == B.left
        L = L1 == :closed ? :closed : L2
    elseif A.left < B.left
        L = L1
    else
        L = L2
    end
    if A.right == B.right
        R = R1 == :closed ? :closed : R2
    elseif A.right > B.right
        R = R1
    else
        R = R2
    end
    left = min(A.left, B.left)
    right = max(A.right, B.right)

    Interval{L,R}(left, right)
end


issubset(A::Interval, B::Interval) = ((A.left in B) && (A.right in B)) || isempty(A)

⊇(A::Interval, B::Interval) = issubset(B, A)

"""
    w = width(iv)

Calculate the width (max-min) of interval `iv`. Note that for integers
`l` and `r`, `width(l..r) = length(l:r) - 1`.
"""
function width(A::Interval{L,R,T}) where {L,R,T}
    _width = A.right - A.left
    max(zero(_width), _width)   # this works when T is a Date
end

length(A::Interval{L,R,T}) where {L,R,T<:Integer} = max(0, Int(A.right - A.left) + 1)

length(A::Interval{L,R,Date}) where {L,R} = max(0, Dates.days(A.right - A.left) + 1)

ClosedInterval{T}(i::UnitRange{I}) where {T,I<:Integer} = ClosedInterval{T}(minimum(i), maximum(i))
ClosedInterval(i::UnitRange{I}) where {I<:Integer} = ClosedInterval{I}(minimum(i), maximum(i))
UnitRange{I}(i::ClosedInterval) where {I<:Integer} = UnitRange{I}(minimum(i), maximum(i))
UnitRange(i::ClosedInterval{I}) where {I<:Integer} = UnitRange{I}(i)
range(i::ClosedInterval{I}) where {I<:Integer} = UnitRange{I}(i)

Base.promote_rule(::Type{Interval{L,R,T1}}, ::Type{Interval{L,R,T2}}) where {L,R,T1,T2} = Interval{L,R,promote_type(T1, T2)}


# convert should only work if they represent the same thing.
@deprecate convert(::Type{R}, i::ClosedInterval{I}) where {R<:AbstractUnitRange,I<:Integer} R(i)
