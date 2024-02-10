@testset "Unitful interval" begin
    @test 1.5u"m" in 1u"m" .. 2u"m"
    @test 1500u"μm" in 1u"mm" .. 1u"m"
    @test !(500u"μm" in 1u"mm" .. 1u"m")
    @test 1u"m" .. 2u"m" == 1000u"mm" .. 2000u"mm"
end

@testset "Day interval" begin
    A = Date(1990, 1, 1); B = Date(1990, 3, 1)
    @test width(ClosedInterval(A, B)) == Dates.Day(59)
    @test width(ClosedInterval(B, A)) == Dates.Day(0)
    @test isempty(ClosedInterval(B, A))
end
