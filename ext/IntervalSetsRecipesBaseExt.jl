module IntervalSetsRecipesBaseExt

using IntervalSets
using RecipesBase

@recipe function f(I::AbstractInterval; offset=0.0)
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
        [a,b], [offset, offset]
    end
    if isleftopen(I)
        @series begin
            seriestype := :scatter
            primary := false
            markerstrokewidth := 0
            markersize := r-w
            markercolor := c
            [a], [offset]
        end
    end
    if isrightopen(I)
        @series begin
            seriestype := :scatter
            primary := false
            markerstrokewidth := 0
            markersize := r-w
            markercolor := c
            [b], [offset]
        end
    end
end

end
