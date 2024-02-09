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

    @testset "Logo" begin
        I₁ = iv"(19.676, 71.327)"
        I₂ = iv"[2.675, 49.676]"
        I₃ = iv"[71.326, 96.326)"
        I₄ = I₁ ∩ I₂
        pl = plot(I₁, offset=-5.00, color=Colors.JULIA_LOGO_COLORS[3], linewidth=30, markersize=60, aspectratio=1)
        plot!(pl, I₂, offset=-25.0, color=Colors.JULIA_LOGO_COLORS[2], linewidth=30, markersize=60)
        plot!(pl, I₃, offset=-37.5, color=Colors.JULIA_LOGO_COLORS[4], linewidth=30, markersize=60)
        plot!(pl, I₄, offset=-50.0, color=Colors.JULIA_LOGO_COLORS[1], linewidth=30, markersize=60)

        path_img = joinpath(dir_out, "Logo.png")
        @test !isfile(path_img)
        savefig(pl, path_img)
        @test isfile(path_img)
    end
end
