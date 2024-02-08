module IntervalSetsRecipesBaseExt

using IntervalSets
using RecipesBase

@recipe function f(I::Interval{L,R,<:Real}) where {L,R}
    a, b = Float64.(extrema(I))
    c = get(plotattributes, :background_color, :white)
    w = get(plotattributes, :linewidth, 3)
    r = get(plotattributes, :markersize, 8)
    @series begin
        seriestype := :line
        primary := true
        marker := :circle
        markerstrokewidth := 0
        markersize := r
        linewidth := w
        [a,b], [0.0, 0.0]
    end
    if isleftopen(I)
        @series begin
            seriestype := :scatter
            primary := false
            markerstrokewidth := 0
            markersize := r-w
            markercolor := c
            [a], [0.0]
        end
    end
    if isrightopen(I)
        @series begin
            seriestype := :scatter
            primary := false
            markerstrokewidth := 0
            markersize := r-w
            markercolor := c
            [b], [0.0]
        end
    end
end

end
