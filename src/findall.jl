"""
    findall(in(interval), x::AbstractRange)

Return all indices `i` for which `x[i] ∈ interval`, specialized for
the case where `x` is a range, which enables constant-time complexity.

# Examples

```jldoctest
julia> x = range(0,stop=3,length=10)
0.0:0.3333333333333333:3.0

julia> collect(x)'
1×10 LinearAlgebra.Adjoint{Float64,Array{Float64,1}}:
 0.0  0.333333  0.666667  1.0  1.33333  1.66667  2.0  2.33333  2.66667  3.0

julia> findall(in(1..6), x)
4:10
```

It also works for decreasing ranges:
```jldoctest
julia> y = 8:-0.5:0
8.0:-0.5:0.0

julia> collect(y)'
1×17 LinearAlgebra.Adjoint{Float64,Array{Float64,1}}:
 8.0  7.5  7.0  6.5  6.0  5.5  5.0  4.5  4.0  3.5  3.0  2.5  2.0  1.5  1.0  0.5  0.0

julia> findall(in(1..6), y)
5:15

julia> findall(in(Interval{:open,:closed}(1,6)), y) # (1,6], does not include 1
5:14
```
"""
function Base.findall(interval_d::Base.Fix2{typeof(in),Interval{L,R,T}}, x::AbstractRange)  where {L,R,T}
    interval = interval_d.x
    il, ir = firstindex(x), lastindex(x)
    δx = step(x)
    if δx < 0
        rev = findall(in(interval), reverse(x))
        return (il+ir)-last(rev):(il+ir)-first(rev)
    end

    lx, rx = first(x), last(x)
    l = max(leftendpoint(interval), lx-1)
    r = min(rightendpoint(interval), rx+1)

    (l > rx || r < lx) && return 1:0

    a = max(il, ceil(Int, (l-lx)/δx) + il)
    b = min(ir, ceil(Int, (r-lx)/δx))
    a + (x[a] == l && L == :open):b + (b < ir && x[b+1] == r && R == :closed)
end
