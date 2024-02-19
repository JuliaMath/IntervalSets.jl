using SortingNetworks # not a permanent solution as the package is not maintained. However it's really fast
import StaticArrays: SVector

"""
    leftof(I1::TypedEndpointsInterval, I2::TypedEndpointsInterval)

Returns if `I1` has a part to the left of `I2`.
"""
function leftof(I1::TypedEndpointsInterval{L1,R1}, I2::TypedEndpointsInterval{L2,R2}) where {L1,R1,L2,R2}
    if leftendpoint(I1) < leftendpoint(I2)
        true
    elseif leftendpoint(I1) > leftendpoint(I2)
        false
    elseif L1 == :closed && L2 == :open
        true
    else
        false
    end
end

"""
    canunion(d1, d2)

Returns if `d1 ∪ d2` is a single interval.
"""
@inline canunion(d1, d2) = any(∈(d1), endpoints(d2)) || any(∈(d2), endpoints(d1))

function tupleunion(I::Tuple{Vararg{TypedEndpointsInterval,N}}) where N
    T = promote_type(map(eltype, I))
    next = iterate(I)
    while !isnothing(next)
        (item, state) = next
        # find the first non-empty interval
        if isempty(item)
            next = iterate(I, state)
            continue
        end
        L = leftendpointtype(item)
        R = rightendpointtype(item)
        l = leftendpoint(item)
        r = rightendpoint(item)
        next = iterate(I, state)
        while !isnothing(next)
            (item, state) = next
            if isempty(item)
            elseif leftendpoint(item) > r
                throw(ArgumentError("IntervalSets doesn't support union of disjoint intervals, while the interval $r..$(leftendpoint(item)) is not covered. Try using DomainSets.UnionDomain for disjoint intervals or ∪(a,b,c...) if the intervals are not sorted."))
            elseif R==:open && leftendpoint(item)==r && leftendpointtype(item)==:open
                throw(ArgumentError("IntervalSets doesn't support union of disjoint intervals, while the point $r is not covered. Try using DomainSets.UnionDomain for disjoint intervals or ∪(a,b,c...) if the intervals are not sorted."))
            else
                (r,R) = _right_union_type(Val{R}, Val{rightendpointtype(item)}, r, rightendpoint(item))
            end
            next = iterate(I, state)
        end
        return Interval{L,R,T}(l,r)
    end
    return one(T)..zero(T) # can't find the first non-empty interval. return an empty interval.
end
# workaround since SortingNetworks.jl doesn't support `lt` keyword argument
Base.minmax(I1::TypedEndpointsInterval, I2::TypedEndpointsInterval) = leftof(I1,I2) ? (I1,I2) : (I2,I1)

# good old union
function union2(d1::TypedEndpointsInterval{L1,R1,T1}, d2::TypedEndpointsInterval{L2,R2,T2}) where {L1,R1,T1,L2,R2,T2}
    T = promote_type(T1,T2)
    isempty(d1) && return Interval{L2,R2,T}(d2)
    isempty(d2) && return Interval{L1,R1,T}(d1)
    any(∈(d1), endpoints(d2)) || any(∈(d2), endpoints(d1)) ||
        throw(ArgumentError("Cannot construct union of disjoint sets."))
    _union(d1, d2)
end
