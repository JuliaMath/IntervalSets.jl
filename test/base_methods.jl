@testset "float" begin
    i1 = 1..2
    @test i1 isa ClosedInterval{Int}
    @test float(i1) isa ClosedInterval{Float64}
    @test float(i1) == i1
    i2 = big(1)..2
    @test i2 isa ClosedInterval{BigInt}
    @test float(i2) isa ClosedInterval{BigFloat}
    @test float(i2) == i2
    i3 = OpenInterval(1,2)
    @test i3 isa OpenInterval{Int}
    @test float(i3) isa OpenInterval{Float64}
    @test float(i3) == i3
    i4 = OpenInterval(1.,2.)
    @test i4 isa OpenInterval{Float64}
    @test float(i4) isa OpenInterval{Float64}
    @test float(i4) == i4
end

@testset "OneTo" begin
    @test_throws ArgumentError Base.OneTo{Int}(0..5)
    @test_throws ArgumentError Base.OneTo(0..5)
    @test Base.OneTo(1..5) == Base.OneTo{Int}(1..5) == Base.OneTo(5)
    @test Base.Slice(1..5) == Base.Slice{UnitRange{Int}}(1..5) == Base.Slice(1:5)
end

@testset "range" begin
    @test range(0..1, 10) == range(0; stop=1, length=10)
    @test range(0..1; length=10) == range(0; stop=1, length=10)
    @test range(0..1; step=1/10) == range(0; stop=1, step=1/10)
    @test range(Interval{:closed,:open}(0..1), 10) == range(0; step=1/10, length=10)
    @test range(Interval{:closed,:open}(0..1); length=10) == range(0; step=1/10, length=10)
    @test range(Interval{:open,:closed}(0..1), 10) == range(; stop=1, step=1/10, length=10)
    @test range(Interval{:open,:closed}(0..1); length=10) == range(1/10; step=1/10, length=10)
    @test range(OpenInterval(0..1), 7) == range(; stop=7/8, step=1/8, length=7)
    @test range(OpenInterval(0..1); length=7) == range(1/8; step=1/8, length=7)
end

@testset "clamp" begin
    @test clamp(1, 0..3) == 1
    @test clamp(1.0, 1.5..3) == 1.5
    @test clamp(1.0, 0..0.5) == 0.5
    @test clamp.([pi, 1.0, big(10.)], Ref(2..9.)) == [big(pi), 2, 9]
end

@testset "mod" begin
    @test mod(10, 0..3) === 1
    @test mod(-10, 0..3) === 2
    @test mod(10.5, 0..3) == 1.5
    @test mod(10.5, 1..1) |> isnan
    @test mod(10.5, Interval{:open, :open}(0, 3)) == 1.5
    @test mod(10.5, Interval{:open, :open}(1, 1)) |> isnan

    @test_throws DomainError mod(0, Interval{:open, :open}(0, 3))
    for x in (0, 3, 0.0, -0.0, 3.0, -eps())
        @test mod(x, Interval{:closed, :open}(0, 3))::typeof(x) == 0
        @test mod(x, Interval{:open, :closed}(0, 3))::typeof(x) == 3
    end
end

@testset "isapprox" begin
    @test 1..2 ≈ 1..2
    @test 1..2 ≈ (1+1e-10)..2
    @test 1..2 ≉ 1..2.01
    @test 10..11 ≈ 10.1..10.9  rtol=0.01
    @test 10..11 ≈ 10.1..10.9  atol=0.1
    @test 10..11 ≉ 10.1..10.9  rtol=0.005
    @test 10..11 ≉ 10.1..10.9  atol=0.05
    @test 0..1 ≈ eps()..1
    @test 100.0..100.0 ≉ nextfloat(100.0)..100.0
    @test 3..1 ≈ 5..1

    # See discussion in https://github.com/JuliaMath/IntervalSets.jl/pull/129
    @test_throws Exception OpenInterval(0, 1) ≈ ClosedInterval(0, 1)
end

@testset "rand" begin
    @test rand(1..2) isa Float64
    @test rand(1..2.) isa Float64
    @test rand(1..big(2)) isa BigFloat
    @test rand(1..(3//2)) isa Float64
    @test rand(Int32(1)..Int32(2)) isa Float64
    @test rand(Float32(1)..Float32(2)) isa Float32
    @test_throws ArgumentError rand(2..1)

    i1 = 1..2
    i2 = 3e100..3e100
    i3 = 1..typemax(Float64)
    i4 = typemin(Float64)..1
    @testset "rand test for $(i)" for i in [i1,i2,i3,i4]
        for _ in 1:100
            @test rand(i1) in i1
            @test rand(i1,10) ⊆ i1
        end
    end

    # If the width is too big, the return value is NaN (sadly).
    i5 = typemin(Float64)..typemax(Float64)
    @test_broken rand(i5) in i5
    @test_broken rand(i5,10) ⊆ i5
    @test_broken !isnan(rand(i5))
    @test_broken !isnan(rand(i5,10))

    # special test to catch issue mentioned at the end of https://github.com/JuliaApproximation/DomainSets.jl/pull/112
    struct RandTestUnitInterval <: TypedEndpointsInterval{:closed, :closed, Float64} end
    IntervalSets.endpoints(::RandTestUnitInterval) = (-1.0, 1.0)
    @test rand(RandTestUnitInterval()) in -1.0..1.0
end
