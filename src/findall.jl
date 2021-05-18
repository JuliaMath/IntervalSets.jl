"""
    findall(in(interval), x::AbstractRange)

Return all indices `i` for which `x[i] ∈ interval`, specialized for
the case where `x` is a range, which enables constant-time complexity.

# Examples

```jldoctest
julia> x = range(0,stop=3,length=10)
0.0:0.3333333333333333:3.0

julia> collect(x)'
1×10 adjoint(::Vector{Float64}) with eltype Float64:
 0.0  0.333333  0.666667  1.0  1.33333  1.66667  2.0  2.33333  2.66667  3.0

julia> findall(in(1..6), x)
4:10
```

It also works for decreasing ranges:
```jldoctest
julia> y = 8:-0.5:0
8.0:-0.5:0.0

julia> collect(y)'
1×17 adjoint(::Vector{Float64}) with eltype Float64:
 8.0  7.5  7.0  6.5  6.0  5.5  5.0  4.5  4.0  3.5  3.0  2.5  2.0  1.5  1.0  0.5  0.0

julia> findall(in(1..6), y)
5:15

julia> findall(in(Interval{:open,:closed}(1,6)), y) # (1,6], does not include 1
5:14
```
"""
function Base.findall(interval_d::Base.Fix2{typeof(in),Interval{L,R,T}}, x::AbstractRange)  where {L,R,T}
    isempty(x) && return 1:0

    interval = interval_d.x
    il, ir = firstindex(x), lastindex(x)
    δx = step(x)
    a,b = if δx < 0
        rev = findall(in(interval), reverse(x))
        isempty(rev) && return rev

        a = (il+ir)-last(rev)
        b = (il+ir)-first(rev)

        a,b
    else
        lx, rx = first(x), last(x)
        l = max(leftendpoint(interval), lx-1)
        r = min(rightendpoint(interval), rx+1)

        (l > rx || r < lx) && return 1:0

        a = il + max(0, round(Int, cld(l-lx, δx)))
        a += (a ≤ ir && (x[a] == l && L == :open || x[a] < l))

        b = min(ir, round(Int, cld(r-lx, δx)) + il)
        b -= (b ≥ il && (x[b] == r && R == :open || x[b] > r))

        a,b
    end
    # Reversing a range could change sign of values close to zero (cf
    # sign of the smallest element in x and reverse(x), where x =
    # range(BigFloat(-0.5),stop=BigFloat(1.0),length=10)), or more
    # generally push elements in or out of the interval (as can cld),
    # so we need to check once again.
    a += +(a < ir && x[a] ∉ interval) - (il < a && x[a-1] ∈ interval)
    b += -(il < b && x[b] ∉ interval) + (b < ir && x[b+1] ∈ interval)

    a:b
end

# We overload Base._findin to avoid an ambiguity that arises with
# Base.findall(interval_d::Base.Fix2{typeof(in),Interval{L,R,T}}, x::AbstractArray)
function Base._findin(a::Union{AbstractArray, Tuple}, b::Interval)
    ind  = Vector{eltype(keys(a))}()
    @inbounds for (i,ai) in pairs(a)
        ai in b && push!(ind, i)
    end
    ind
end
