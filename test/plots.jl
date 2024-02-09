@testset "plot" begin
    dir_out = joinpath(@__DIR__, "out_plot")
    rm(dir_out; force=true, recursive=true)
    mkpath(dir_out)

    @testset "TypedEndpointsInterval" begin
        pl = plot(iv"[1,2]"; aspectratio=1)
        plot!(pl, iv"(4,5)"; aspectratio=1)
        plot!(pl, iv"[6,8)"; aspectratio=1)
        plot!(pl, iv"(9,9.2]"; aspectratio=1)

        path_img = joinpath(dir_out, "TypedEndpointsInterval.png")
        @test !isfile(path_img)
        savefig(pl, path_img)
        @test isfile(path_img)
    end
end
