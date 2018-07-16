"""
A `ClosedInterval(left, right)` is an interval set that includes both its upper and lower bounds. In
mathematical notation, the constructed range is `[left, right]`.
"""
struct ClosedInterval{T} <: AbstractInterval{T}
    left::T
    right::T

    ClosedInterval{T}(l::T, r::T) where {T} = new{T}(l, r)
    ClosedInterval{T}(l, r) where {T} = ((a, b) = checked_conversion(T, l, r); new{T}(a, b))
    ClosedInterval{T}(i::AbstractInterval) where {T} = convert(ClosedInterval{T}, i)
end

function ClosedInterval(left, right)
    # Defining this as ClosedInterval(promote(left, right)...) has one problem:
    # if left and right do not promote to a common type, it triggers a StackOverflow.
    T = promote_type(typeof(left), typeof(right))
    ClosedInterval{T}(checked_conversion(T, left, right)...)
end

ClosedInterval(i::AbstractInterval) = convert(ClosedInterval{eltype(i)}, i)

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

in(v, I::ClosedInterval) = I.left <= v <= I.right
in(a::ClosedInterval, b::ClosedInterval) = (b.left <= a.left) & (a.right <= b.right)

isempty(A::ClosedInterval) = A.left > A.right

isequal(A::ClosedInterval, B::ClosedInterval) = isequal(A.left, B.left) & isequal(A.right, B.right)

isless(A::ClosedInterval, B::ClosedInterval) = isless(A.left, B.left) | (isequal(A.left, B.left) & isless(A.right, B.right))

==(A::ClosedInterval, B::ClosedInterval) = (A.left == B.left && A.right == B.right) || (isempty(A) && isempty(B))

const _closed_interval_hash = UInt == UInt64 ? 0x1588c274e0a33ad4 : 0x1e3f7252

hash(I::ClosedInterval, h::UInt) = hash(I.left, hash(I.right, hash(_closed_interval_hash, h)))

minimum(I::ClosedInterval) = I.left
maximum(I::ClosedInterval) = I.right
extrema(I::ClosedInterval) = (minimum(I), maximum(I))

function intersect(A::ClosedInterval, B::ClosedInterval)
    left = max(A.left, B.left)
    right = min(A.right, B.right)
    ClosedInterval(left, right)
end

function union(A::ClosedInterval{T}, B::ClosedInterval{T}) where T<:AbstractFloat
    max(A.left, B.left) <= nextfloat(min(A.right, B.right)) || throw(ArgumentError("Cannot construct union of disjoint sets."))
    _union(A, B)
end

function union(A::ClosedInterval, B::ClosedInterval)
    max(A.left, B.left) <= min(A.right, B.right) || throw(ArgumentError("Cannot construct union of disjoint sets."))
    _union(A, B)
end

function _union(A::ClosedInterval, B::ClosedInterval)
    left = min(A.left, B.left)
    right = max(A.right, B.right)
    ClosedInterval(left, right)
end

issubset(A::ClosedInterval, B::ClosedInterval) = ((A.left in B) && (A.right in B)) || isempty(A)

⊇(A::ClosedInterval, B::ClosedInterval) = issubset(B, A)

"""
    w = width(iv)

Calculate the width (max-min) of interval `iv`. Note that for integers
`l` and `r`, `width(l..r) = length(l:r) - 1`.
"""
function width(A::ClosedInterval{T}) where T
    _width = A.right - A.left
    max(zero(_width), _width)   # this works when T is a Date
end

length(A::ClosedInterval{T}) where {T<:Integer} = max(0, Int(A.right - A.left) + 1)

length(A::ClosedInterval{Date}) = max(0, Dates.days(A.right - A.left) + 1)

function convert(::Type{R}, i::ClosedInterval{I}) where {R<:AbstractUnitRange,I<:Integer}
    R(minimum(i), maximum(i))
end

range(i::ClosedInterval{I}) where {I<:Integer} = convert(UnitRange{I}, i)

Base.promote_rule(::Type{ClosedInterval{T1}}, ::Type{ClosedInterval{T2}}) where {T1,T2} = ClosedInterval{promote_type(T1, T2)}
