using IntervalSets
using Test
using Dates
using Statistics
import Statistics: mean
using Random
using Unitful
using Plots
using Printf

import IntervalSets: Domain, endpoints, closedendpoints, TypedEndpointsInterval

using Aqua
Aqua.test_all(IntervalSets)

struct MyClosedUnitInterval <: TypedEndpointsInterval{:closed,:closed,Int} end
endpoints(::MyClosedUnitInterval) = (0,1)
Base.promote_rule(::Type{MyClosedUnitInterval}, ::Type{ClosedInterval{T}}) where T =
        ClosedInterval{T}

struct MyUnitInterval <: AbstractInterval{Int}
    isleftclosed::Bool
    isrightclosed::Bool
end
endpoints(::MyUnitInterval) = (0,1)
closedendpoints(I::MyUnitInterval) = (I.isleftclosed,I.isrightclosed)

struct IncompleteInterval <: AbstractInterval{Int} end

@testset "IntervalSets" begin

    @testset "ordered" begin
        @test ordered(2, 1) == (1, 2)
        @test ordered(1, 2) == (1, 2)
        @test ordered(Float16(1), 2) == (1, 2)
    end

    @testset "iv_str macro" begin
        @test iv"[1,2]" === 1..2
        @test iv"[1,2)" === Interval{:closed, :open}(1, 2)
        @test iv"(1,2]" === Interval{:open, :closed}(1, 2)
        @test iv"(1,2)" === OpenInterval(1, 2)

        for (a,b) in ((1,2), (1.4,3.9), (ℯ,π))
            @test iv"[a,b]" === a..b
            @test iv"[a,b)" === Interval{:closed, :open}(a, b)
            @test iv"(a,b]" === Interval{:open, :closed}(a, b)
            @test iv"(a,b)" === OpenInterval(a, b)
        end

        @test_throws Exception iv"[(1,2)]"
        @test_throws Exception iv"[1,2,]"
        @test_throws Exception iv"[(1,2]"
        @test_throws Exception iv"[(1,,2]"
        @test_throws Exception iv"[1..2]"
        @test_throws Exception iv"(1..2)"
        @test_throws Exception iv"[1...2]"
        @test_throws Exception iv"(1...2)"
        @test_throws Exception iv"1..2"
    end

    @testset "Basic Closed Sets" begin
        @test_throws ErrorException :a .. "b"
        @test_throws ErrorException 1 .. missing
        @test_throws ErrorException 1u"m" .. 2u"s"
        I = 0..3
        @test I === ClosedInterval(0,3)
        @test I === ClosedInterval{Int}(0,3)
        @test I === Interval(0,3)
        @test string(I) == "0 .. 3"
        @test @inferred(UnitRange(I)) === 0:3
        @test @inferred(range(I)) === 0:3
        @test @inferred(UnitRange{Int16}(I)) === Int16(0):Int16(3)
        @test @inferred(ClosedInterval(0:3)) === I
        @test @inferred(ClosedInterval{Float64}(0:3)) === 0.0..3.0
        @test @inferred(ClosedInterval(Base.OneTo(3))) === 1..3
        J = 3..2
        K = 5..4
        L = 3 ± 2
        M = @inferred(ClosedInterval(2, 5.0))
        @test string(M) == "2.0 .. 5.0"
        N = @inferred(ClosedInterval(UInt8(255), 300))

        x, y = CartesianIndex(1, 2, 3, 4), CartesianIndex(1, 2, 3, 4)
        O = @inferred x±y
        @test O == ClosedInterval(x-y, x+y)

        @test eltype(I) == Int
        @test eltype(M) == Float64

        @test !isempty(I)
        @test isempty(J)
        @test J == K
        @test I != K
        @test I == I
        @test J == J
        @test L == L
        @test isequal(I, I)
        @test isequal(J, K)

        @test typeof(leftendpoint(M)) == typeof(rightendpoint(M)) && typeof(leftendpoint(M)) == Float64
        @test typeof(leftendpoint(N)) == typeof(rightendpoint(N)) && typeof(leftendpoint(N)) == Int
        @test @inferred(endpoints(M)) === (2.0,5.0)
        @test @inferred(endpoints(N)) === (255,300)

        @test maximum(I) === 3
        @test minimum(I) === 0
        @test extrema(I) === (0, 3)

        @test 2 in I
        @test issubset(1..2, 0.5..2.5)

        @test @inferred(I ∪ L) == ClosedInterval(0, 5)
        @test @inferred(I ∩ L) == ClosedInterval(1, 3)
        @test isempty(J ∩ K)
        @test isempty((2..5) ∩ (7..10))
        @test isempty((1..10) ∩ (7..2))
        A = Float16(1.1)..Float16(1.234)
        B = Float16(1.235)..Float16(1.3)
        C = Float16(1.236)..Float16(1.3)
        D = Float16(1.1)..Float16(1.236)
        @test D ∪ B == Float16(1.1)..Float16(1.3)
        @test D ∪ C == Float16(1.1)..Float16(1.3)
        @test_throws(ArgumentError, A ∪ C)

        @test 1.5 ∉ 0..1
        @test 1.5 ∉ 2..3
        # Throw error if the union is not an interval.
        @test_throws ArgumentError (0..1) ∪ (2..3)
        # Even though A and B contain all Float16s between their extrema,
        # union should not defined because there exists a Float64 inbetween.
        @test_throws ArgumentError A ∪ B
        x32 = nextfloat(rightendpoint(A))
        x64 = nextfloat(Float64(rightendpoint(A)))
        @test x32 ∉ A
        @test x32 ∈ B
        @test x64 ∉ A
        @test x64 ∉ B

        @test J ⊆ L
        @test (L ⊆ J) == false
        @test K ⊆ I
        @test ClosedInterval(1, 2) ⊆ I
        @test I ⊆ I
        @test (ClosedInterval(7, 9) ⊆ I) == false
        @test I ⊇ I
        @test I ⊇ ClosedInterval(1, 2)
        @test !(I ⊊ I)
        @test !(I ⊋ I)
        @test !(I ⊊ J)
        @test !(J ⊋ I)
        @test J ⊊ I
        @test I ⊋ J

        @test hash(1..3) == hash(1.0..3.0)

        @test width(I) == 3
        @test width(J) == 0

        @test width(ClosedInterval(3,7)) ≡ 4
        @test width(ClosedInterval(4.0,8.0)) ≡ 4.0

        @test mean(0..1) == 0.5

        @test promote(1..2, 1.0..2.0) === (1.0..2.0, 1.0..2.0)
    end

    @testset "Convert" begin
        I = 0..3
        @test 0.0..3.0 === @inferred(convert(ClosedInterval{Float64}, I))
        @test 0.0..3.0 === @inferred(convert(AbstractInterval{Float64}, I))
        @test 0.0..3.0 === @inferred(convert(Domain{Float64}, I))
        @test 0.0..3.0 === @inferred(ClosedInterval{Float64}(I))
        @test 0.0..3.0 === @inferred(convert(TypedEndpointsInterval{:closed,:closed,Float64},I))
        @test I === @inferred(convert(ClosedInterval, I))
        @test I === @inferred(convert(Interval, I))
        @test I === @inferred(ClosedInterval(I))
        @test I === @inferred(Interval(I))
        @test I === @inferred(convert(AbstractInterval, I))
        @test I === @inferred(convert(Domain, I))
        @test I === @inferred(convert(TypedEndpointsInterval{:closed,:closed}, I))
        @test I === @inferred(convert(TypedEndpointsInterval{:closed,:closed,Int}, I))
        @test I === @inferred(convert(ClosedInterval{Int}, I))
        @test_throws InexactError convert(OpenInterval, I)
        @test_throws InexactError convert(Interval{:open,:closed}, I)
        @test_throws InexactError convert(Interval{:closed,:open}, I)
        @test !(convert(ClosedInterval{Float64}, I) === 0..3)
        @test ClosedInterval{Float64}(1,3) === 1.0..3.0
        @test ClosedInterval(0.5..2.5) === 0.5..2.5
        @test ClosedInterval{Int}(1.0..3.0) === 1..3

        J = OpenInterval(I)
        @test_throws InexactError convert(ClosedInterval, J)
        @test iv"(0.,3.)" === @inferred(convert(OpenInterval{Float64}, J))
        @test iv"(0.,3.)" === @inferred(convert(AbstractInterval{Float64}, J))
        @test iv"(0.,3.)" === @inferred(convert(Domain{Float64}, J))
        @test iv"(0.,3.)" === @inferred(OpenInterval{Float64}(J))
        @test OpenInterval(J) === @inferred(convert(OpenInterval, J))
        @test OpenInterval(J) === @inferred(convert(Interval, J))
        @test OpenInterval(J) === @inferred(convert(AbstractInterval, J))
        @test OpenInterval(J) === @inferred(convert(Domain, J))
        @test OpenInterval(J) === @inferred(OpenInterval(J))
        @test OpenInterval(J) === @inferred(OpenInterval{Int}(J))
        @test OpenInterval(J) === @inferred(convert(OpenInterval{Int},J))

        J = Interval{:open,:closed}(I)
        @test_throws InexactError convert(Interval{:closed,:open}, J)
        @test iv"(0.,3.]" === @inferred(convert(Interval{:open,:closed,Float64}, J))
        @test iv"(0.,3.]" === @inferred(convert(AbstractInterval{Float64}, J))
        @test iv"(0.,3.]" === @inferred(convert(Domain{Float64}, J))
        @test iv"(0.,3.]" === @inferred(Interval{:open,:closed,Float64}(J))
        @test Interval{:open,:closed}(J) === @inferred(convert(Interval{:open,:closed}, J))
        @test Interval{:open,:closed}(J) === @inferred(convert(Interval, J))
        @test Interval{:open,:closed}(J) === @inferred(convert(AbstractInterval, J))
        @test Interval{:open,:closed}(J) === @inferred(convert(Domain, J))
        @test Interval{:open,:closed}(J) === @inferred(Interval{:open,:closed}(J))

        J = Interval{:closed,:open}(I)
        @test_throws InexactError convert(Interval{:open,:closed}, J)
        @test iv"[0.,3.)" === @inferred(convert(Interval{:closed,:open,Float64}, J))
        @test iv"[0.,3.)" === @inferred(convert(AbstractInterval{Float64}, J))
        @test iv"[0.,3.)" === @inferred(convert(Domain{Float64}, J))
        @test iv"[0.,3.)" === @inferred(Interval{:closed,:open,Float64}(J))
        @test Interval{:closed,:open}(J) === @inferred(convert(Interval{:closed,:open}, J))
        @test Interval{:closed,:open}(J) === @inferred(convert(Interval, J))
        @test Interval{:closed,:open}(J) === @inferred(convert(AbstractInterval, J))
        @test Interval{:closed,:open}(J) === @inferred(convert(Domain, J))
        @test Interval{:closed,:open}(J) === @inferred(Interval{:closed,:open}(J))

        @test 1.0..2.0 === 1.0..2 === 1..2.0 === ClosedInterval{Float64}(1..2) === Interval(1.0,2.0)
        @test promote_type(Interval{:closed,:open,Float64}, Interval{:closed,:open,Int}) === Interval{:closed,:open,Float64}
    end

    @testset "Interval tests" begin
        for T in (Float32,Float64,BigFloat)
            d = zero(T) .. one(T)
            @test T(0.5) ∈ d
            @test T(1.1) ∉ d
            @test 0.5f0 ∈ d
            @test 1.1f0 ∉ d
            @test BigFloat(0.5) ∈ d
            @test BigFloat(1.1) ∉ d
            @test leftendpoint(d) ∈ d
            @test BigFloat(leftendpoint(d)) ∈ d
            @test nextfloat(leftendpoint(d)) ∈ d
            @test nextfloat(BigFloat(leftendpoint(d))) ∈ d
            @test prevfloat(leftendpoint(d)) ∉ d
            @test prevfloat(leftendpoint(d)) ∉ d
            @test rightendpoint(d) ∈ d
            @test BigFloat(rightendpoint(d)) ∈ d
            @test nextfloat(rightendpoint(d)) ∉ d
            @test nextfloat(BigFloat(rightendpoint(d))) ∉ d
            @test prevfloat(rightendpoint(d)) ∈ d
            @test prevfloat(rightendpoint(d)) ∈ d

            @test leftendpoint(d) == zero(T)
            @test rightendpoint(d) == one(T)
            @test minimum(d) == infimum(d) == leftendpoint(d)
            @test maximum(d) == supremum(d) == rightendpoint(d)

            @test IntervalSets.isclosedset(d)
            @test !IntervalSets.isopenset(d)
            @test IntervalSets.isleftclosed(d)
            @test !IntervalSets.isleftopen(d)
            @test !IntervalSets.isrightopen(d)
            @test IntervalSets.isrightclosed(d)

            @test convert(AbstractInterval, d) ≡ d
            @test convert(AbstractInterval{T}, d) ≡ d
            @test convert(IntervalSets.Domain, d) ≡ d
            @test convert(IntervalSets.Domain{T}, d) ≡ d

            d = OpenInterval(zero(T) .. one(T))
            @test IntervalSets.isopenset(d)
            @test !IntervalSets.isclosedset(d)
            @test IntervalSets.isopenset(d)
            @test !IntervalSets.isclosedset(d)
            @test !IntervalSets.isleftclosed(d)
            @test IntervalSets.isleftopen(d)
            @test IntervalSets.isrightopen(d)
            @test !IntervalSets.isrightclosed(d)
            @test leftendpoint(d) ∉ d
            @test BigFloat(leftendpoint(d)) ∉ d
            @test nextfloat(leftendpoint(d)) ∈ d
            @test nextfloat(BigFloat(leftendpoint(d))) ∈ d
            @test prevfloat(leftendpoint(d)) ∉ d
            @test prevfloat(leftendpoint(d)) ∉ d
            @test rightendpoint(d) ∉ d
            @test BigFloat(rightendpoint(d)) ∉ d
            @test nextfloat(rightendpoint(d)) ∉ d
            @test nextfloat(BigFloat(rightendpoint(d))) ∉ d
            @test prevfloat(rightendpoint(d)) ∈ d
            @test prevfloat(rightendpoint(d)) ∈ d
            @test infimum(d) == leftendpoint(d)
            @test supremum(d) == rightendpoint(d)
            @test_throws ArgumentError minimum(d)
            @test_throws ArgumentError maximum(d)

            @test isempty(OpenInterval(1,1))

            d = Interval{:open,:closed}(zero(T) .. one(T))
            @test !IntervalSets.isopenset(d)
            @test !IntervalSets.isclosedset(d)
            @test !IntervalSets.isleftclosed(d)
            @test IntervalSets.isleftopen(d)
            @test !IntervalSets.isrightopen(d)
            @test IntervalSets.isrightclosed(d)
            @test leftendpoint(d) ∉ d
            @test BigFloat(leftendpoint(d)) ∉ d
            @test nextfloat(leftendpoint(d)) ∈ d
            @test nextfloat(BigFloat(leftendpoint(d))) ∈ d
            @test prevfloat(leftendpoint(d)) ∉ d
            @test prevfloat(BigFloat(leftendpoint(d))) ∉ d
            @test rightendpoint(d) ∈ d
            @test BigFloat(rightendpoint(d)) ∈ d
            @test nextfloat(rightendpoint(d)) ∉ d
            @test nextfloat(BigFloat(rightendpoint(d))) ∉ d
            @test prevfloat(rightendpoint(d)) ∈ d
            @test prevfloat(BigFloat(rightendpoint(d))) ∈ d
            @test infimum(d) == leftendpoint(d)
            @test maximum(d) == supremum(d) == rightendpoint(d)
            @test_throws ArgumentError minimum(d)

            d = Interval{:closed,:open}(zero(T) .. one(T))
            @test !IntervalSets.isopenset(d)
            @test !IntervalSets.isclosedset(d)
            @test IntervalSets.isleftclosed(d)
            @test !IntervalSets.isleftopen(d)
            @test IntervalSets.isrightopen(d)
            @test !IntervalSets.isrightclosed(d)
            @test leftendpoint(d) ∈ d
            @test BigFloat(leftendpoint(d)) ∈ d
            @test nextfloat(leftendpoint(d)) ∈ d
            @test nextfloat(BigFloat(leftendpoint(d))) ∈ d
            @test prevfloat(leftendpoint(d)) ∉ d
            @test prevfloat(BigFloat(leftendpoint(d))) ∉ d
            @test rightendpoint(d) ∉ d
            @test BigFloat(rightendpoint(d)) ∉ d
            @test nextfloat(rightendpoint(d)) ∉ d
            @test nextfloat(BigFloat(rightendpoint(d))) ∉ d
            @test prevfloat(rightendpoint(d)) ∈ d
            @test prevfloat(BigFloat(rightendpoint(d))) ∈ d
            @test infimum(d) == minimum(d) == leftendpoint(d)
            @test supremum(d) == rightendpoint(d)
            @test_throws ArgumentError maximum(d)


            # - empty interval
            @test isempty(one(T) .. zero(T))
            @test zero(T) ∉ one(T) .. zero(T)

            d = one(T) .. zero(T)
            @test_throws ArgumentError minimum(d)
            @test_throws ArgumentError maximum(d)
            @test_throws ArgumentError infimum(d)
            @test_throws ArgumentError supremum(d)
        end
    end

    @testset "Custom intervals" begin
        I = MyUnitInterval(true,true)
        @test eltype(I) == eltype(typeof(I)) == Int
        @test leftendpoint(I) == 0
        @test rightendpoint(I) == 1
        @test isleftclosed(I)
        @test !isleftopen(I)
        @test isrightclosed(I)
        @test !isrightopen(I)
        @test 0..1 === ClosedInterval(I)
        @test 0..1 === convert(ClosedInterval, I)
        @test 0..1 === ClosedInterval{Int}(I)
        @test 0..1 === convert(ClosedInterval{Int}, I)
        @test 0..1 === convert(Interval, I)
        @test 0..1 === Interval(I)
        @test_throws InexactError convert(OpenInterval, I)

        I = MyUnitInterval(false,false)
        @test leftendpoint(I) == 0
        @test rightendpoint(I) == 1
        @test !isleftclosed(I)
        @test !isrightclosed(I)
        @test iv"(0,1)" === OpenInterval(I)
        @test iv"(0,1)" === convert(OpenInterval, I)
        @test iv"(0,1)" === OpenInterval{Int}(I)
        @test iv"(0,1)" === convert(OpenInterval{Int}, I)
        @test iv"(0,1)" === convert(Interval, I)

        I = MyUnitInterval(false,true)
        @test leftendpoint(I) == 0
        @test rightendpoint(I) == 1
        @test isleftclosed(I) == false
        @test isrightclosed(I) == true
        @test iv"(0,1]" === Interval{:open,:closed}(I)
        @test iv"(0,1]" === convert(Interval{:open,:closed}, I)
        @test iv"(0,1]" === Interval{:open,:closed,Int}(I)
        @test iv"(0,1]" === convert(Interval{:open,:closed,Int}, I)
        @test iv"(0,1]" === convert(Interval, I)
        @test iv"(0,1]" === Interval(I)

        I = MyUnitInterval(true,false)
        @test leftendpoint(I) == 0
        @test rightendpoint(I) == 1
        @test isleftclosed(I) == true
        @test isrightclosed(I) == false
        @test iv"[0,1)" === Interval{:closed,:open}(I)
        @test iv"[0,1)" === convert(Interval{:closed,:open}, I)
        @test iv"[0,1)" === Interval{:closed,:open,Int}(I)
        @test iv"[0,1)" === convert(Interval{:closed,:open,Int}, I)
        @test iv"[0,1)" === convert(Interval, I)
        @test iv"[0,1)" === Interval(I)
        @test convert(AbstractInterval, I) === convert(AbstractInterval{Int}, I) === I
    end

    @testset "Custom typed endpoints interval" begin
        I = MyClosedUnitInterval()
        @test leftendpoint(I) == 0
        @test rightendpoint(I) == 1
        @test isleftclosed(I) == true
        @test isrightclosed(I) == true
        @test ClosedInterval(I) === convert(ClosedInterval, I) ===
                ClosedInterval{Int}(I) === convert(ClosedInterval{Int}, I)  ===
                convert(Interval, I) === Interval(I) === 0..1
        @test_throws InexactError convert(OpenInterval, I)
        @test I ∩ I === 0..1
        @test I ∩ (0.0..0.5) === 0.0..0.5
    end

    @testset "closedendpoints" begin
        @test closedendpoints(0..1) == closedendpoints(MyClosedUnitInterval()) == (true,true)
        @test closedendpoints(Interval{:open,:closed}(0,1)) == (false,true)
        @test closedendpoints(Interval{:closed,:open}(0,1)) == (true,false)
        @test closedendpoints(OpenInterval(0,1)) == (false,false)
    end

    @testset "IteratorSize" begin
        @test Base.IteratorSize(ClosedInterval) == Base.SizeUnknown()
    end

    @testset "IncompleteInterval" begin
        I = IncompleteInterval()
        @test eltype(I) === Int
        @test_throws ErrorException endpoints(I)
        @test_throws ErrorException closedendpoints(I)
        @test_throws MethodError 2 in I
    end

    @testset "stringify" begin
        @test string(0..1) == "0 .. 1"
        @test string(iv"[0,1)") == "0 .. 1 (closed-open)"
        @test @sprintf("%d", 0..1) == "0 .. 1"
        @test @sprintf("%.2f", 0..1) == "0.00 .. 1.00"
        @test @sprintf("%.2f", iv"[0,1)") == "0.00 .. 1.00 (closed-open)"
        @test @sprintf("%.2f", 0u"m"..1u"m") == "0.00 m .. 1.00 m"
    end

    include("base_methods.jl")
    include("setoperations.jl")
    include("findall.jl")
    include("nonreal_interval.jl")
    include("plots.jl")
end
