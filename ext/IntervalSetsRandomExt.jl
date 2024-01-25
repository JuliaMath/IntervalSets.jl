module IntervalSetRandomExt

using IntervalSets
using IntervalSets: TypedEndpointsInterval
using Random

# random sampling from interval
Random.gentype(::Type{Interval{L,R,T}}) where {L,R,T} = float(T)
function Random.rand(rng::AbstractRNG, i::Random.SamplerTrivial{<:TypedEndpointsInterval{:closed, :closed, T}}) where T<:Real
    _i = i[]
    isempty(_i) && throw(ArgumentError("The interval should be non-empty."))
    a,b = endpoints(_i)
    t = rand(rng, float(T)) # technically this samples from [0, 1), but we still allow it with TypedEndpointsInterval{:closed, :closed} for convenience
    return clamp(t*a+(1-t)*b, _i)
end

end
