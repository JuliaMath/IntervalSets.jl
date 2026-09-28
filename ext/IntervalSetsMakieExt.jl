module IntervalSetsMakieExt

using IntervalSets
using Makie

"""
    plot(I::AbstractInterval; kwargs...)
    plot!(I::AbstractInterval; kwargs...)

plots the interval `I` with Makie as a line between its endpoints, with a filled marker at a closed
endpoint and a hollow marker at an open endpoint.
"""
@recipe IntervalPlot (interval,) begin
    "Height at which the interval is drawn."
    offset = 0.0
    "Color of the line and the endpoint markers."
    color = @inherit linecolor
    "Width of the line, and of the outline of an open endpoint."
    linewidth = 3
    "Size of the endpoint markers."
    markersize = 12
    "Fill color of the marker at an open endpoint."
    backgroundcolor = @inherit backgroundcolor
    cycle = [:color]
end

Makie.plottype(::AbstractInterval) = IntervalPlot

_endpointpoints(I, offset, keep) = [Point2f(x, offset) for (x, k) in zip(endpoints(I), keep) if k]

function Makie.plot!(p::IntervalPlot)
    I, offset = p[:interval], p[:offset]
    ends = lift((I, offset) -> _endpointpoints(I, offset, (true, true)), p, I, offset)
    closed = lift((I, offset) -> _endpointpoints(I, offset, (isleftclosed(I), isrightclosed(I))), p, I, offset)
    open = lift((I, offset) -> _endpointpoints(I, offset, (isleftopen(I), isrightopen(I))), p, I, offset)
    lines!(p, ends; color=p[:color], linewidth=p[:linewidth])
    scatter!(p, closed; color=p[:color], markersize=p[:markersize], strokewidth=0)
    # an open endpoint is drawn over the line in the background color, with an outline in the interval's color.
    # The outline is centred on the edge of the marker, so this gives the same outer size as a closed endpoint.
    holesize = lift((m, w) -> m - w/2, p, p[:markersize], p[:linewidth])
    strokewidth = lift(w -> w/2, p, p[:linewidth])
    scatter!(p, open; color=p[:backgroundcolor], strokecolor=p[:color], strokewidth, markersize=holesize)
    p
end

end
