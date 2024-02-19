"""
An `Interval{L,R}(left, right)` where L,R are :open or :closed
is an interval set containg `x` such that
1. `left ≤ x ≤ right` if `L == R == :closed`
2. `left < x ≤ right` if `L == :open` and `R == :closed`
3. `left ≤ x < right` if `L == :closed` and `R == :open`, or
4. `left < x < right` if `L == R == :open`
"""
struct Interval{L,R,T}  <: TypedEndpointsInterval{L,R,T}
    left::T
    right::T

    Interval{L,R,T}(l, r) where {L,R,T} = ((a, b) = checked_conversion(T, l, r); new{L,R,T}(a, b))
end


"""
A `ClosedInterval(left, right)` is an interval set that includes both its upper and lower bounds. In
mathematical notation, the constructed range is `[left, right]`.
"""
const ClosedInterval{T} = Interval{:closed,:closed,T}

"""
An `TypedEndpointsInterval{:open,:open}(left, right)` is an interval set that includes both its upper and lower bounds. In
mathematical notation, the constructed range is `(left, right)`.
"""
const OpenInterval{T} = Interval{:open,:open,T}

Interval{L,R,T}(i::AbstractInterval) where {L,R,T} = Interval{L,R,T}(endpoints(i)...)
Interval{L,R}(left, right) where {L,R} = Interval{L,R}(promote(left,right)...)
Interval{L,R}(left::T, right::T) where {L,R,T} = Interval{L,R,T}(left, right)
Interval(left, right) = ClosedInterval(left, right)


# Interval(::AbstractInterval) allows open/closed intervals to be changed
Interval{L,R}(i::AbstractInterval) where {L,R} = Interval{L,R}(endpoints(i)...)
Interval(i::AbstractInterval) = Interval{isleftclosed(i) ? (:closed) : (:open),
                                         isrightclosed(i) ? (:closed) : (:open)}(i)
Interval(i::TypedEndpointsInterval{L,R}) where {L,R} = Interval{L,R}(i)

"""
    @iv_str -> Interval

Construct an interval with mathematical notation such as `iv"(1,2]"`.

# Examples
```jldoctest
julia> iv"[1,2]"
1 .. 2

julia> iv"[1,2)"
1 .. 2 (closed-open)

julia> iv"(1,2]"
1 .. 2 (open-closed)

julia> iv"(1,2)"
1 .. 2 (open)
```
"""
macro iv_str(s)
    msg = "Invalid expresson `$s`"
    for (reg, f) ∈ (
        (r"^\[(.*)\)$", Interval{:closed, :open}),
        (r"^\((.*)\)$", Interval{:open, :open}),
        (r"^\((.*)\]$", Interval{:open, :closed}),
        (r"^\[(.*)\]$", Interval{:closed, :closed}),
    )
        m = match(reg, s)
        if !isnothing(m)
            try
                args = Meta.parse("("*m.captures[1]*",)")
                if args.head === :incomplete
                    return :(throw(ErrorException("$($msg)")))
                elseif length(args.args) ≠ 2
                    return :(throw(ErrorException("$($msg)")))
                else
                    return :($f($(esc(args))...))
                end
            catch
                return :(throw(ErrorException("$($msg)")))
            end
        end
    end
    return :(throw(ErrorException("$($msg)")))
end

endpoints(i::Interval) = (i.left, i.right)

for L in (:(:open),:(:closed)), R in (:(:open),:(:closed))
    @eval begin
        convert(::Type{Interval{$L,$R}}, i::Interval{$L,$R}) = i
        convert(::Type{Interval{$L,$R,T}}, i::Interval{$L,$R,T}) where T = i
    end
end
convert(::Type{Interval}, i::Interval) = i

function convert(::Type{II}, i::AbstractInterval) where II<:ClosedInterval
    isclosedset(i) ||  throw(InexactError(:convert,II,i))
    II(i)
end
function convert(::Type{II}, i::AbstractInterval) where II<:OpenInterval
    isopenset(i) ||  throw(InexactError(:convert,II,i))
    II(i)
end
function convert(::Type{II}, i::AbstractInterval) where II<:Interval{:open,:closed}
    (isleftopen(i) && isrightclosed(i)) ||  throw(InexactError(:convert,II,i))
    II(i)
end
function convert(::Type{II}, i::AbstractInterval) where II<:Interval{:closed,:open}
    (isleftclosed(i) && isrightopen(i)) ||  throw(InexactError(:convert,II,i))
    II(i)
end

convert(::Type{Interval}, i::AbstractInterval) = Interval(i)

convert(::Type{Domain{T}}, d::Interval{L,R}) where {L,R,T} = convert(Interval{L,R,T}, d)
convert(::Type{AbstractInterval{T}}, d::Interval{L,R}) where {L,R,T} = convert(Interval{L,R,T}, d)
convert(::Type{AbstractInterval{T}}, d::Interval{L,R,T}) where {L,R,T} = convert(Interval{L,R,T}, d)
convert(::Type{TypedEndpointsInterval{L,R,T}}, d::Interval{L,R}) where {L,R,T} = convert(Interval{L,R,T}, d)
convert(::Type{TypedEndpointsInterval{L,R,T}}, d::Interval{L,R,T}) where {L,R,T} = convert(Interval{L,R,T}, d)
convert(::Type{Domain}, d::Interval{L,R}) where {L,R} = d
convert(::Type{AbstractInterval}, d::Interval{L,R}) where {L,R} = d
convert(::Type{TypedEndpointsInterval{L,R}}, d::Interval{L,R}) where {L,R} = d


"""
    iv = l..r

Construct a ClosedInterval `iv` spanning the region from `l` to `r`.

# Examples
```jldoctest
julia> 1..2
1 .. 2

julia> 3..1  # Empty interval set can be defined
3 .. 1
```
"""
..(x, y) = ClosedInterval(x, y)


"""
    iv = center ± halfwidth

Construct a ClosedInterval `iv` spanning the region from
`center - halfwidth` to `center + halfwidth`.

# Examples
```jldoctest
julia> 3 ± 2
1 .. 5
```
"""
±(x, y) = ClosedInterval(x - y, x + y)
±(x::CartesianIndex, y::CartesianIndex) = ClosedInterval(x-y, x+y)

show(io::IO, I::ClosedInterval) = print(io, leftendpoint(I), " .. ", rightendpoint(I))
show(io::IO, I::OpenInterval) = print(io, leftendpoint(I), " .. ", rightendpoint(I), " (open)")
show(io::IO, I::Interval{:open,:closed}) = print(io, leftendpoint(I), " .. ", rightendpoint(I), " (open-closed)")
show(io::IO, I::Interval{:closed,:open}) = print(io, leftendpoint(I), " .. ", rightendpoint(I), " (closed-open)")

leftendpointtype(::TypedEndpointsInterval{L,R}) where {L,R} = L
rightendpointtype(::TypedEndpointsInterval{L,R}) where {L,R} = R

# The following are not typestable for mixed endpoint types
_left_intersect_type(::Type{Val{:open}}, ::Type{Val{L2}}, a1, a2) where L2 = a1 < a2 ? (a2,L2) : (a1,:open)
_left_intersect_type(::Type{Val{:closed}}, ::Type{Val{L2}}, a1, a2) where L2 = a1 ≤ a2 ? (a2,L2) : (a1,:closed)
_right_intersect_type(::Type{Val{:open}}, ::Type{Val{R2}}, b1, b2) where R2 = b1 > b2 ? (b2,R2) : (b1,:open)
_right_intersect_type(::Type{Val{:closed}}, ::Type{Val{R2}}, b1, b2) where R2 = b1 ≥ b2 ? (b2,R2) : (b1,:closed)
_left_union_type(::Type{Val{:open}}, ::Type{Val{L2}}, a1, a2) where L2 = a1 < a2 ? (a1,:open) : (a2,L2)
_left_union_type(::Type{Val{:closed}}, ::Type{Val{L2}}, a1, a2) where L2 = a1 ≤ a2 ? (a1,:closed) : (a2,L2)
_right_union_type(::Type{Val{:open}}, ::Type{Val{R2}}, b1, b2) where R2 = b1 > b2 ? (b1,:open) : (b2,R2)
_right_union_type(::Type{Val{:closed}}, ::Type{Val{R2}}, b1, b2) where R2 = b1 ≥ b2 ? (b1,:closed) : (b2,R2)

function intersect(d1::TypedEndpointsInterval{L1,R1}, d2::TypedEndpointsInterval{L2,R2}) where {L1,R1,L2,R2}
    a1, b1 = endpoints(d1); a2, b2 = endpoints(d2)
    a,L = _left_intersect_type(Val{L1}, Val{L2}, a1, a2)
    b,R = _right_intersect_type(Val{R1}, Val{R2}, b1, b2)
    Interval{L,R}(a,b)
end

function intersect(d1::TypedEndpointsInterval{L,R}, d2::TypedEndpointsInterval{L,R}) where {L,R}
    a1, b1 = endpoints(d1); a2, b2 = endpoints(d2)
    Interval{L,R}(max(a1,a2),min(b1,b2))
end

intersect(d1::AbstractInterval, d2::AbstractInterval) = intersect(Interval(d1), Interval(d2))

include("unionalgorithms.jl")

union(d::TypedEndpointsInterval) = d # 1 interval
union(d1::TypedEndpointsInterval, d2::TypedEndpointsInterval) = union2(d1, d2) # 2 intervals
Base.@nexprs(23,N -> union(I::Vararg{TypedEndpointsInterval,N+2}) = tupleunion(swapsort(I))) # 3 to 25 intervals
union(I::TypedEndpointsInterval...) = tupleunion(sort(SVector(I); lt = leftof)) # ≥26 intervals

# these assume overlap
function _union(A::TypedEndpointsInterval{L,R}, B::TypedEndpointsInterval{L,R}) where {L,R}
    left = min(leftendpoint(A), leftendpoint(B))
    right = max(rightendpoint(A), rightendpoint(B))
    Interval{L,R}(left, right)
end

# this is not typestable
function _union(A::TypedEndpointsInterval{L1,R1}, B::TypedEndpointsInterval{L2,R2}) where {L1,R1,L2,R2}
    if leftendpoint(A) == leftendpoint(B)
        L = L1 == :closed ? :closed : L2
    elseif leftendpoint(A) < leftendpoint(B)
        L = L1
    else
        L = L2
    end
    if rightendpoint(A) == rightendpoint(B)
        R = R1 == :closed ? :closed : R2
    elseif rightendpoint(A) > rightendpoint(B)
        R = R1
    else
        R = R2
    end
    left = min(leftendpoint(A), leftendpoint(B))
    right = max(rightendpoint(A), rightendpoint(B))

    Interval{L,R}(left, right)
end

ClosedInterval{T}(i::AbstractUnitRange{I}) where {T,I<:Integer} = ClosedInterval{T}(minimum(i), maximum(i))
ClosedInterval(i::AbstractUnitRange{I}) where {I<:Integer} = ClosedInterval{I}(minimum(i), maximum(i))

Base.promote_rule(::Type{Interval{L,R,T1}}, ::Type{Interval{L,R,T2}}) where {L,R,T1,T2} = Interval{L,R,promote_type(T1, T2)}

float(i::Interval{L, R, T}) where {L,R,T} = Interval{L, R, float(T)}(endpoints(i)...)
