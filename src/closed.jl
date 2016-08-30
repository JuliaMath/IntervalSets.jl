"""
A `ClosedInterval(left, right)` is an interval set that includes both its upper and lower bounds. In 
mathematical notation, the constructed range is `[left, right]`.
"""
immutable ClosedInterval{T}
    left::T
    right::T
end

ClosedInterval(left, right) = ClosedInterval(promote(left, right)...)

..(x, y) = ClosedInterval(x, y)

±(x, y) = ClosedInterval(x - y, x + y)
±(x::CartesianIndex, y) = map(ClosedInterval, (x - y).I, (x + y).I)

show(io::IO, I::ClosedInterval) = print(io, I.left, "..", I.right)

in(v, I::ClosedInterval) = I.left <= v <= I.right

isempty(A::ClosedInterval) = A.left > A.right

isequal(A::ClosedInterval, B::ClosedInterval) = (isequal(A.left, B.left) & isequal(A.right, B.right)) | (isempty(A) & isempty(B))

==(A::ClosedInterval, B::ClosedInterval) = (A.left == B.left && A.right == B.right) || (isempty(A) && isempty(B))

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
