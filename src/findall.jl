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
 8.0  7.5  7.0  6.5  6.0  5.5  5.0  4.5  …  3.0  2.5  2.0  1.5  1.0  0.5  0.0

julia> findall(in(1..6), y)
5:15

julia> findall(in(Interval{:open,:closed}(1,6)), y) # (1,6], does not include 1
5:14
```
"""
Base.findall(interval_d::Base.Fix2{typeof(in), <:Interval}, x::AbstractRange) =
    searchsorted_interval(x, interval_d.x; rev=step(x) < zero(step(x)))

# We overload Base._findin to avoid an ambiguity that arises with
# Base.findall(interval_d::Base.Fix2{typeof(in),Interval{L,R,T}}, x::AbstractArray)
function Base._findin(a::Union{AbstractArray, Tuple}, b::Interval)
    ind  = Vector{eltype(keys(a))}()
    @inbounds for (i,ai) in pairs(a)
        ai in b && push!(ind, i)
    end
    ind
end

"""
    searchsorted_interval(a, i::Interval; [rev=false])

Return the range of indices of `a` which is inside of the interval `i` (using binary search), assuming that
`a` is already sorted. Return an empty range located at the insertion point if a does not contain values in `i`.

# Examples
```jldoctest
julia> searchsorted_interval([1,2,3,5], 2..4)
2:3

julia> searchsorted_interval([1,2,3,5], 4..1)
4:3

julia> searchsorted_interval(Float64[], 1..3)
1:0
```
"""
function searchsorted_interval(X, i::Interval{L, R}; rev=false) where {L, R}
    ord = Base.Order.ord(<, identity, rev)
    if rev === true
        _searchsorted_begin(X, rightendpoint(i), Val(R), ord):_searchsorted_end(X, leftendpoint(i), Val(L), ord)
    else
        _searchsorted_begin(X, leftendpoint(i), Val(L), ord):_searchsorted_end(X, rightendpoint(i), Val(R), ord)
    end
end

_searchsorted_begin(X, x, ::Val{:closed}, ord) = searchsortedfirst(X, x, ord)
_searchsorted_begin(X, x,   ::Val{:open}, ord) =  searchsortedlast(X, x, ord) + 1
  _searchsorted_end(X, x, ::Val{:closed}, ord) =  searchsortedlast(X, x, ord)
  _searchsorted_end(X, x,   ::Val{:open}, ord) = searchsortedfirst(X, x, ord) - 1
