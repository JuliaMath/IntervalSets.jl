using IntervalSets
using Compat
using Compat.Test
using Compat.Dates


@testset "IntervalSets" begin
    @test ordered(2, 1) == (1, 2)
    @test ordered(1, 2) == (1, 2)
    @test ordered(Float16(1), 2) == (1, 2)

    @testset "Closed Sets" begin
        @test_throws ArgumentError :a .. "b"
        I = 0..3
        @test string(I) == "0..3"
        @test @inferred(UnitRange(I)) === 0:3
        @test @inferred(range(I)) === 0:3
        @test @inferred(UnitRange{Int16}(I)) === Int16(0):Int16(3)
        J = 3..2
        K = 5..4
        L = 3 ± 2
        M = @inferred(ClosedInterval(2, 5.0))
        @test string(M) == "2.0..5.0"
        N = @inferred(ClosedInterval(UInt8(255), 300))
        O = @inferred(CartesianIndex(1, 2, 3, 4) ± 2)
        @test O == (-1..3, 0..4, 1..5, 2..6)

        @test eltype(I) == Int
        @test eltype(M) == Float64
        @test @inferred(convert(ClosedInterval{Float64}, I)) === 0.0..3.0
        @test @inferred(ClosedInterval{Float64}(0:3)) === 0.0..3.0
        @test !(convert(ClosedInterval{Float64}, I) === 0..3)
        @test ClosedInterval{Float64}(1,3) === 1.0..3.0
        @test ClosedInterval(0.5..2.5) === 0.5..2.5
        @test ClosedInterval{Int}(1.0..3.0) === 1..3

        @test !isempty(I)
        @test isempty(J)
        @test J == K
        @test I != K
        @test I == I
        @test J == J
        @test L == L
        @test isequal(I, I)
        @test isequal(J, K)

        @test typeof(M.left) == typeof(M.right) && typeof(M.left) == Float64
        @test typeof(N.left) == typeof(N.right) && typeof(N.left) == Int

        @test maximum(I) === 3
        @test minimum(I) === 0
        @test extrema(I) === (0, 3)

        @test 2 in I
        @test 1..2 in 0.5..2.5

        @test @inferred(I ∪ L) == ClosedInterval(0, 5)
        @test @inferred(I ∩ L) == ClosedInterval(1, 3)
        @test isempty(J ∩ K)
        @test isempty((2..5) ∩ (7..10))
        @test isempty((1..10) ∩ (7..2))
        A = Float16(1.1)..nextfloat(Float16(1.234))
        B = Float16(1.235)..Float16(1.3)
        C = Float16(1.236)..Float16(1.3)
        D = Float16(1.1)..Float16(1.236)
        @test A ∪ B == Float16(1.1)..Float16(1.3)
        @test D ∪ B == Float16(1.1)..Float16(1.3)
        @test D ∪ C == Float16(1.1)..Float16(1.3)
        @test_throws(ArgumentError, A ∪ C)

        @test J ⊆ L
        @test (L ⊆ J) == false
        @test K ⊆ I
        @test ClosedInterval(1, 2) ⊆ I
        @test I ⊆ I
        @test (ClosedInterval(7, 9) ⊆ I) == false
        @test I ⊇ I
        @test I ⊇ ClosedInterval(1, 2)

        @test hash(1..3) == hash(1.0..3.0)

        let A = Date(1990, 1, 1), B = Date(1990, 3, 1)
            @test width(ClosedInterval(A, B)) == Dates.Day(59)
            @test width(ClosedInterval(B, A)) == Dates.Day(0)
            @test isempty(ClosedInterval(B, A))
            @test length(ClosedInterval(A, B)) ≡ 60
            @test length(ClosedInterval(B, A)) ≡ 0
        end

        @test width(ClosedInterval(3,7)) ≡ 4
        @test width(ClosedInterval(4.0,8.0)) ≡ 4.0

        @test promote(1..2, 1.0..2.0) === (1.0..2.0, 1.0..2.0)

        @test length(I) == 4
        @test length(J) == 0
        # length deliberately not defined for non-integer intervals
        @test_throws MethodError length(1.2..2.4)
    end
end

function test_interval(T = Float64)
    println("- intervals")

    d = interval(zero(T), one(T))
    @test T(0.5) ∈ d
    @test T(1.1) ∉ d
    @test 0.5f0 ∈ d
    @test 1.1f0 ∉ d
    @test BigFloat(0.5) ∈ d
    @test BigFloat(1.1) ∉ d
    @test approx_in(-0.1, d, 0.2)
    @test approx_in(1.1, d, 0.2)
    @test !approx_in(-0.2, d, 0.1)
    @test !approx_in(1.2, d, 0.1)

    @test leftendpoint(d) == zero(T)
    @test rightendpoint(d) == one(T)
    @test minimum(d) == infimum(d) == leftendpoint(d)
    @test maximum(d) == supremum(d) == rightendpoint(d)

    @test isclosed(d)
    @test !isopen(d)
    @test iscompact(d)
    @test typeof(similar_interval(d, one(T), 2*one(T))) == typeof(d)

    @test leftendpoint(d) ∈ ∂(d)
    @test rightendpoint(d) ∈ ∂(d)

    d = UnitInterval{T}()
    @test leftendpoint(d) == zero(T)
    @test rightendpoint(d) == one(T)
    @test minimum(d) == infimum(d) == leftendpoint(d)
    @test maximum(d) == supremum(d) == rightendpoint(d)

    @test isclosed(d)
    @test !isopen(d)
    @test iscompact(d)

    @test convert(Domain, d) ≡ d
    @test convert(Domain{T}, d) ≡ d
    @test convert(AbstractInterval, d) ≡ d
    @test convert(AbstractInterval{T}, d) ≡ d
    @test convert(UnitInterval, d) ≡ d
    @test convert(UnitInterval{T}, d) ≡ d
    @test convert(Domain{Float64}, d) ≡ UnitInterval()
    @test convert(AbstractInterval{Float64}, d) ≡ UnitInterval()
    @test convert(UnitInterval{Float64}, d) ≡ UnitInterval()


    d = ChebyshevInterval{T}()
    @test leftendpoint(d) == -one(T)
    @test rightendpoint(d) == one(T)
    @test minimum(d) == infimum(d) == leftendpoint(d)
    @test maximum(d) == supremum(d) == rightendpoint(d)

    @test isclosed(d)
    @test !isopen(d)
    @test iscompact(d)

    @test convert(Domain, d) ≡ d
    @test convert(Domain{T}, d) ≡ d
    @test convert(AbstractInterval, d) ≡ d
    @test convert(AbstractInterval{T}, d) ≡ d
    @test convert(ChebyshevInterval, d) ≡ d
    @test convert(ChebyshevInterval{T}, d) ≡ d
    @test convert(Domain{Float64}, d) ≡ ChebyshevInterval()
    @test convert(AbstractInterval{Float64}, d) ≡ ChebyshevInterval()
    @test convert(ChebyshevInterval{Float64}, d) ≡ ChebyshevInterval()

    d = halfline(T)
    @test leftendpoint(d) == zero(T)
    @test rightendpoint(d) == T(Inf)
    @test minimum(d) == infimum(d) == leftendpoint(d)
    @test supremum(d) == rightendpoint(d)
    @test_throws ArgumentError maximum(d)

    @test !isclosed(d)
    @test !isopen(d)
    @test !iscompact(d)
    @test 1. ∈ d
    @test -1. ∉ d
    @test approx_in(-0.1, d, 0.5)
    @test !approx_in(-0.5, d, 0.1)
    @test similar_interval(d, T(0), T(Inf)) == d

    @test leftendpoint(d) ∈ ∂(d)
    @test rightendpoint(d) ∉ ∂(d)


    d = negative_halfline(T)
    @test leftendpoint(d) == -T(Inf)
    @test rightendpoint(d) == zero(T)
    @test infimum(d) == leftendpoint(d)
    @test maximum(d) == supremum(d) == rightendpoint(d)
    @test_throws ArgumentError minimum(d)

    @test !isclosed(d)
    @test isopen(d)
    @test !iscompact(d)
    @test -1. ∈ d
    @test 1. ∉ d
    @test approx_in(0.5, d, 1.)
    @test !approx_in(0.5, d, 0.4)
    @test similar_interval(d, T(-Inf), T(0)) == d


    d = Domains.open_interval()
    @test isopen(d)
    @test !isclosed(d)
    @test leftendpoint(d)∉d
    @test rightendpoint(d)∉d
    @test infimum(d) == leftendpoint(d)
    @test supremum(d) == rightendpoint(d)
    @test_throws ArgumentError minimum(d)
    @test_throws ArgumentError maximum(d)
    @test leftendpoint(d) ∉ ∂(d)
    @test rightendpoint(d) ∉ ∂(d)

    @test isempty(OpenInterval(1,1))

    d = Domains.closed_interval()
    @test !isopen(d)
    @test isclosed(d)
    @test leftendpoint(d) ∈ d
    @test rightendpoint(d) ∈ d
    @test minimum(d) == infimum(d) == leftendpoint(d)
    @test maximum(d) == supremum(d) == rightendpoint(d)
    @test leftendpoint(d) ∈ ∂(d)
    @test rightendpoint(d) ∈ ∂(d)

    d = HalfOpenLeftInterval()
    @test !isopen(d)
    @test !isclosed(d)
    @test leftendpoint(d) ∉ d
    @test rightendpoint(d) ∈ d
    @test infimum(d) == leftendpoint(d)
    @test maximum(d) == supremum(d) == rightendpoint(d)
    @test_throws ArgumentError minimum(d)
    @test leftendpoint(d) ∉ ∂(d)
    @test rightendpoint(d) ∈ ∂(d)

    d = HalfOpenRightInterval()
    @test !isopen(d)
    @test !isclosed(d)
    @test leftendpoint(d) ∈ d
    @test rightendpoint(d) ∉ d
    @test minimum(d) == infimum(d) == leftendpoint(d)
    @test supremum(d) == rightendpoint(d)
    @test_throws ArgumentError maximum(d)
    @test leftendpoint(d) ∈ ∂(d)
    @test rightendpoint(d) ∉ ∂(d)

    @test typeof(UnitInterval{Float64}(interval(0.,1.))) <: UnitInterval
    @test typeof(ChebyshevInterval{Float64}(interval(-1,1.))) <: ChebyshevInterval

    ## Some mappings preserve the interval structure
    # Translation
    d = interval(zero(T), one(T))
    @test d == +d

    d2 = d + one(T)
    @test typeof(d2) == typeof(d)
    @test leftendpoint(d2) == one(T)
    @test rightendpoint(d2) == 2*one(T)

    d2 = one(T) + d
    @test typeof(d2) == typeof(d)
    @test leftendpoint(d2) == one(T)
    @test rightendpoint(d2) == 2*one(T)

    d2 = d - one(T)
    @test typeof(d2) == typeof(d)
    @test leftendpoint(d2) == -one(T)
    @test rightendpoint(d2) == zero(T)

    d2 = -d
    @test typeof(d2) == typeof(d)
    @test leftendpoint(d2) == -one(T)
    @test rightendpoint(d2) == zero(T)

    d2 = one(T) - d
    @test d2 == d

    # translation for UnitInterval
    # Does a shifted unit interval return an interval?
    d = UnitInterval{T}()
    d2 = d + one(T)
    @test typeof(d2) <: AbstractInterval
    @test leftendpoint(d2) == one(T)
    @test rightendpoint(d2) == 2*one(T)

    d2 = one(T) + d
    @test typeof(d2) <: AbstractInterval
    @test leftendpoint(d2) == one(T)
    @test rightendpoint(d2) == 2*one(T)

    d2 = d - one(T)
    @test typeof(d2) <: AbstractInterval
    @test leftendpoint(d2) == -one(T)
    @test rightendpoint(d2) == zero(T)

    d2 = -d
    @test typeof(d2) <: AbstractInterval
    @test leftendpoint(d2) == -one(T)
    @test rightendpoint(d2) == zero(T)

    d2 = one(T) - d
    @test typeof(d2) <: AbstractInterval
    @test leftendpoint(d2) == zero(T)
    @test rightendpoint(d2) == one(T)


    # translation for ChebyshevInterval
    d = ChebyshevInterval{T}()
    d2 = d + one(T)
    @test typeof(d2) <: AbstractInterval
    @test leftendpoint(d2) == zero(T)
    @test rightendpoint(d2) == 2*one(T)

    d2 = one(T) + d
    @test typeof(d2) <: AbstractInterval
    @test leftendpoint(d2) == zero(T)
    @test rightendpoint(d2) == 2*one(T)

    d2 = d - one(T)
    @test typeof(d2) <: AbstractInterval
    @test leftendpoint(d2) == -2one(T)
    @test rightendpoint(d2) == zero(T)

    @test -d == d

    d2 = one(T) - d
    @test typeof(d2) <: AbstractInterval
    @test leftendpoint(d2) == zero(T)
    @test rightendpoint(d2) == 2one(T)


    # Scaling
    d = interval(zero(T), one(T))
    d3 = T(2) * d
    @test typeof(d3) == typeof(d)
    @test leftendpoint(d3) == zero(T)
    @test rightendpoint(d3) == T(2)

    d3 = d * T(2)
    @test typeof(d3) == typeof(d)
    @test leftendpoint(d3) == zero(T)
    @test rightendpoint(d3) == T(2)

    d = interval(zero(T), one(T))
    d4 = d / T(2)
    @test typeof(d4) == typeof(d)
    @test leftendpoint(d4) == zero(T)
    @test rightendpoint(d4) == T(1)/T(2)

    d4 = T(2) \ d
    @test typeof(d4) == typeof(d)
    @test leftendpoint(d4) == zero(T)
    @test rightendpoint(d4) == T(1)/T(2)


    # Union and intersection of intervals
    i1 = interval(zero(T), one(T))
    i2 = interval(one(T)/3, one(T)/2)
    i3 = interval(one(T)/2, 2*one(T))
    i4 = interval(T(2), T(3))
    # - union of completely overlapping intervals
    du1 = i1 ∪ i2
    @test typeof(du1) <: AbstractInterval
    @test leftendpoint(du1) == leftendpoint(i1)
    @test rightendpoint(du1) == rightendpoint(i1)

    # - intersection of completely overlapping intervals
    du2 = i1 ∩ i2
    @test typeof(du2) <: AbstractInterval
    @test leftendpoint(du2) == leftendpoint(i2)
    @test rightendpoint(du2) == rightendpoint(i2)

    # - union of partially overlapping intervals
    du3 = i1 ∪ i3
    @test typeof(du3) <: AbstractInterval
    @test leftendpoint(du3) == leftendpoint(i1)
    @test rightendpoint(du3) == rightendpoint(i3)

    # - intersection of partially overlapping intervals
    du4 = i1 ∩ i3
    @test typeof(du4) <: AbstractInterval
    @test leftendpoint(du4) == leftendpoint(i3)
    @test rightendpoint(du4) == rightendpoint(i1)

    # - union of non-overlapping intervals
    du5 = i1 ∪ i4
    @test typeof(du5) <: UnionDomain

    # - intersection of non-overlapping intervals
    du6 = i1 ∩ i4
    @test typeof(du6) == EmptySpace{T}

    # - setdiff of intervals
    d1 = interval(-2one(T), 2one(T))
    @test d1 \ interval(3one(T), 4one(T)) == d1
    @test d1 \ interval(zero(T), one(T)) == interval(-2one(T),zero(T)) ∪ interval(one(T), 2one(T))
    @test d1 \ interval(zero(T), 3one(T)) == interval(-2one(T),zero(T))
    @test d1 \ interval(-3one(T),zero(T)) == interval(zero(T),2one(T))
    @test d1 \ interval(-4one(T),-3one(T)) == d1
    @test d1 \ interval(-4one(T),4one(T)) == EmptySpace{T}()

    d1 \ (-3one(T)) == d1
    d1 \ (-2one(T)) == Interval{:open,:closed}(-2one(T),2one(T))
    d1 \ (2one(T)) == Interval{:closed,:open}(-2one(T),2one(T))
    d1 \ zero(T) == Interval{:closed,:open}(-2one(T),zero(T)) ∪ Interval{:open,:closed}(zero(T),2one(T))

    # - empty interval
    @test isempty(interval(one(T),zero(T)))
    @test zero(T) ∉ interval(one(T),zero(T))
    @test isempty(Interval{:open,:open}(zero(T),zero(T)))
    @test zero(T) ∉ Interval{:open,:open}(zero(T),zero(T))
    @test isempty(Interval{:open,:closed}(zero(T),zero(T)))
    @test zero(T) ∉ Interval{:open,:closed}(zero(T),zero(T))
    @test isempty(Interval{:closed,:open}(zero(T),zero(T)))
    @test zero(T) ∉ Interval{:closed,:open}(zero(T),zero(T))

    d = interval(one(T),zero(T))
    @test_throws ArgumentError minimum(d)
    @test_throws ArgumentError maximum(d)
    @test_throws ArgumentError infimum(d)
    @test_throws ArgumentError supremum(d)

    # - convert
    d = interval(zero(T), one(T))
    @test d ≡ Interval(zero(T), one(T))
    @test d ≡ ClosedInterval(zero(T), one(T))

    @test convert(Domain, d) ≡ d
    @test Domain(d) ≡ d
    @test convert(Domain{Float32}, d) ≡ interval(0f0, 1f0)
    @test Domain{Float32}(d) ≡ interval(0f0, 1f0)
    @test convert(Domain{Float64}, d) ≡ interval(0.0, 1.0)
    @test Domain{Float64}(d) ≡ interval(0.0, 1.0)
    @test convert(Domain, zero(T)..one(T)) ≡ d
    @test Domain(zero(T)..one(T)) ≡ d
    @test convert(Domain{T}, zero(T)..one(T)) ≡ d
    @test Domain{T}(zero(T)..one(T)) ≡ d
    @test convert(AbstractInterval, zero(T)..one(T)) ≡ d
    @test AbstractInterval(zero(T)..one(T)) ≡ d
    @test convert(AbstractInterval{T}, zero(T)..one(T)) ≡ d
    @test AbstractInterval{T}(zero(T)..one(T)) ≡ d
    @test convert(Interval, zero(T)..one(T)) ≡ d
    @test Interval(zero(T)..one(T)) ≡ d
    @test convert(ClosedInterval, zero(T)..one(T)) ≡ d
    @test ClosedInterval(zero(T)..one(T)) ≡ d
    @test convert(ClosedInterval{T}, zero(T)..one(T)) ≡ d
    @test ClosedInterval{T}(zero(T)..one(T)) ≡ d


    # tests conversion from other types
    @test convert(Domain{T}, 0..1) ≡ d
    @test Domain{T}(0..1) ≡ d
    @test convert(AbstractInterval{T}, 0..1) ≡ d
    @test AbstractInterval{T}(0..1) ≡ d
    @test convert(ClosedInterval{T}, 0..1) ≡ d
    @test ClosedInterval{T}(0..1) ≡ d

end

nothing
