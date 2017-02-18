"""
A `ClosedInterval(left, right)` is an interval set that includes both its upper and lower bounds. In
mathematical notation, the constructed range is `[left, right]`.
"""
immutable ClosedInterval{T} <: AbstractInterval{T}
    left::T
    right::T

    (::Type{ClosedInterval{T}}){T}(l::T, r::T) = new{T}(l, r)
end

ClosedInterval{T}(left::T, right::T) = ClosedInterval{T}(left, right)
(::Type{ClosedInterval{T}}){T}(left, right) =
    ClosedInterval{T}(checked_conversion(T, left, right)...)

function ClosedInterval(left, right)
    # Defining this as ClosedInterval(promote(left, right)...) has one problem:
    # if left and right do not promote to a common type, it triggers a StackOverflow.
    T = promote_type(typeof(left), typeof(right))
    ClosedInterval{T}(checked_conversion(T, left, right)...)
end

ClosedInterval(i::AbstractInterval) = convert(ClosedInterval{eltype(i)}, i)
(::Type{ClosedInterval{T}}){T}(i::AbstractInterval) = convert(ClosedInterval{T}, i)

..(x, y) = ClosedInterval(x, y)

±(x, y) = ClosedInterval(x - y, x + y)
±(x::CartesianIndex, y) = map(ClosedInterval, (x - y).I, (x + y).I)

show(io::IO, I::ClosedInterval) = print(io, I.left, "..", I.right)

in(v, I::ClosedInterval) = I.left <= v <= I.right
in(a::ClosedInterval, b::ClosedInterval) = (b.left <= a.left) & (a.right <= b.right)

isempty(A::ClosedInterval) = A.left > A.right

isequal(A::ClosedInterval, B::ClosedInterval) = (isequal(A.left, B.left) & isequal(A.right, B.right)) | (isempty(A) & isempty(B))

==(A::ClosedInterval, B::ClosedInterval) = (A.left == B.left && A.right == B.right) || (isempty(A) && isempty(B))

const _closed_interval_hash = UInt == UInt64 ? 0x1588c274e0a33ad4 : 0x1e3f7252

hash(I::ClosedInterval, h::UInt) = hash(I.left, hash(I.right, hash(_closed_interval_hash, h)))

minimum(I::ClosedInterval) = I.left
maximum(I::ClosedInterval) = I.right

function intersect(A::ClosedInterval, B::ClosedInterval)
    left = max(A.left, B.left)
    right = min(A.right, B.right)
    ClosedInterval(left, right)
end

function union{T<:AbstractFloat}(A::ClosedInterval{T}, B::ClosedInterval{T})
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

function width{T}(A::ClosedInterval{T})
    _width = A.right - A.left
    max(zero(_width), _width)   # this works when T is a Date
end
