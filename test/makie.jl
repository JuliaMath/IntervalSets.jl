@testset "Makie" begin
    # the points of the line, the closed endpoints and the open endpoints
    points(p) = [map(x -> Tuple(Float64.(x)), c[1][]) for c in p.plots]
    color(c) = Makie.to_color(c[]) # older versions of Makie store colors unconverted

    fig, ax, p = Makie.plot(iv"[1,2)")
    @test p isa Makie.Plot{Base.get_extension(IntervalSets, :IntervalSetsMakieExt).intervalplot}
    @test points(p) == [[(1, 0), (2, 0)], [(1, 0)], [(2, 0)]]

    q = Makie.plot!(ax, iv"(3,4)"; offset=1)
    @test points(q) == [[(3, 1), (4, 1)], [], [(3, 1), (4, 1)]]
    # colors cycle (Makie < 0.24 only cycles between intervals with the same kinds of endpoints)
    @test color(Makie.plot!(ax, iv"[7,8)").color) ≠ color(p.color)

    r = Makie.plot!(ax, 5..6; color=:red, linewidth=4, markersize=20)
    @test points(r) == [[(5, 0), (6, 0)], [(5, 0), (6, 0)], []]
    lin, closed, open = r.plots
    @test color(lin.color) == color(closed.color) == color(open.strokecolor) == Makie.to_color(:red)
    @test lin.linewidth[] == 4
    @test all(==(20), closed.markersize[])

    # an open endpoint has the same outer size as a closed one, with its outline centred on the edge
    lin, closed, open = q.plots
    @test all(==(12 - 3/2), open.markersize[])
    @test open.strokewidth[] == 3/2
    @test color(open.color) == Makie.to_color(:white)
end
