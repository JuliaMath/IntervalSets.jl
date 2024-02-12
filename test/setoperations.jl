@testset "Union and intersection with $T" for T in (Float32,Float64)
    # i1      0 ------>------ 1
    # i2         1/3 ->- 1/2
    # i3                 1/2 ------>------ 2
    # i4                                   2 -->-- 3
    # i5                        1.0+ -->-- 2
    # i_empty 0 ------<------ 1
    i1 = zero(T) .. one(T)
    i2 = one(T)/3 .. one(T)/2
    i3 = one(T)/2 .. 2*one(T)
    i4 = T(2) .. T(3)
    i5 = nextfloat(one(T)) .. 2one(T)
    i_empty = one(T) ..zero(T)

    # - union of completely overlapping intervals
    # i1      0 ------>------ 1
    # i2         1/3 ->- 1/2
    @test (@inferred i1 ∪ i2) ≡ (@inferred i2 ∪ i1) ≡ i1
    @test Interval{:open,:closed}(i1) ∪ Interval{:open,:closed}(i2) ≡
            Interval{:open,:closed}(i2) ∪ Interval{:open,:closed}(i1) ≡ Interval{:open,:closed}(i1)
    @test Interval{:closed,:open}(i1) ∪ Interval{:closed,:open}(i2) ≡
            Interval{:closed,:open}(i2) ∪ Interval{:closed,:open}(i1) ≡ Interval{:closed,:open}(i1)
    @test OpenInterval(i1) ∪ OpenInterval(i2) ≡
            OpenInterval(i2) ∪ OpenInterval(i1) ≡ OpenInterval(i1)
    @test i1 ∪ Interval{:open,:closed}(i2) ≡ Interval{:open,:closed}(i2) ∪ i1 ≡ i1
    @test i1 ∪ Interval{:closed,:open}(i2) ≡ Interval{:closed,:open}(i2) ∪ i1 ≡ i1
    @test i1 ∪ OpenInterval(i2) ≡ OpenInterval(i2) ∪ i1 ≡ i1
    @test OpenInterval(i1) ∪ i2 ≡ i2 ∪ OpenInterval(i1) ≡ OpenInterval(i1)
    @test OpenInterval(i1) ∪ Interval{:open,:closed}(i2) ≡ Interval{:open,:closed}(i2) ∪ OpenInterval(i1) ≡ OpenInterval(i1)
    @test OpenInterval(i1) ∪ Interval{:closed,:open}(i2) ≡ Interval{:closed,:open}(i2) ∪ OpenInterval(i1) ≡ OpenInterval(i1)
    @test Interval{:open,:closed}(i1) ∪ OpenInterval(i2) ≡ OpenInterval(i2) ∪ Interval{:open,:closed}(i1) ≡ Interval{:open,:closed}(i1)
    @test Interval{:open,:closed}(i1) ∪ Interval{:closed,:open}(i2) ≡ Interval{:closed,:open}(i2) ∪ Interval{:open,:closed}(i1) ≡ Interval{:open,:closed}(i1)

    # - intersection of completely overlapping intervals
    # i1      0 ------>------ 1
    # i2         1/3 ->- 1/2
    @test (@inferred i1 ∩ i2) ≡ (@inferred i2 ∩ i1) ≡ i2
    @test Interval{:open,:closed}(i1) ∩ Interval{:open,:closed}(i2) ≡
            Interval{:open,:closed}(i2) ∩ Interval{:open,:closed}(i1) ≡ Interval{:open,:closed}(i2)
    @test Interval{:closed,:open}(i1) ∩ Interval{:closed,:open}(i2) ≡
            Interval{:closed,:open}(i2) ∩ Interval{:closed,:open}(i1) ≡ Interval{:closed,:open}(i2)
    @test OpenInterval(i1) ∩ OpenInterval(i2) ≡
            OpenInterval(i2) ∩ OpenInterval(i1) ≡ OpenInterval(i2)
    @test i1 ∩ Interval{:open,:closed}(i2) ≡ Interval{:open,:closed}(i2) ∩ i1 ≡  Interval{:open,:closed}(i2)
    @test i1 ∩ Interval{:closed,:open}(i2) ≡ Interval{:closed,:open}(i2) ∩ i1 ≡ Interval{:closed,:open}(i2)
    @test i1 ∩ OpenInterval(i2) ≡ OpenInterval(i2) ∩ i1 ≡ OpenInterval(i2)
    @test OpenInterval(i1) ∩ i2 ≡ i2 ∩ OpenInterval(i1) ≡ i2
    @test OpenInterval(i1) ∩ Interval{:open,:closed}(i2) ≡ Interval{:open,:closed}(i2) ∩ OpenInterval(i1) ≡ Interval{:open,:closed}(i2)
    @test OpenInterval(i1) ∩ Interval{:closed,:open}(i2) ≡ Interval{:closed,:open}(i2) ∩ OpenInterval(i1) ≡ Interval{:closed,:open}(i2)
    @test Interval{:open,:closed}(i1) ∩ OpenInterval(i2) ≡ OpenInterval(i2) ∩ Interval{:open,:closed}(i1) ≡ OpenInterval(i2)
    @test Interval{:open,:closed}(i1) ∩ Interval{:closed,:open}(i2) ≡ Interval{:closed,:open}(i2) ∩ Interval{:open,:closed}(i1) ≡ Interval{:closed,:open}(i2)
    @test !isdisjoint(i1, i2)


    # - union of partially overlapping intervals
    # i1      0 ------>------ 1
    # i3                 1/2 ------>------ 2
    d = zero(T) .. 2*one(T)
    @test (@inferred i1 ∪ i3) ≡ (@inferred i3 ∪ i1) ≡ d
    @test Interval{:open,:closed}(i1) ∪ Interval{:open,:closed}(i3) ≡
            Interval{:open,:closed}(i3) ∪ Interval{:open,:closed}(i1) ≡ Interval{:open,:closed}(d)
    @test Interval{:closed,:open}(i1) ∪ Interval{:closed,:open}(i3) ≡
            Interval{:closed,:open}(i3) ∪ Interval{:closed,:open}(i1) ≡ Interval{:closed,:open}(d)
    @test OpenInterval(i1) ∪ OpenInterval(i3) ≡
            OpenInterval(i3) ∪ OpenInterval(i1) ≡ OpenInterval(d)
    @test i1 ∪ Interval{:open,:closed}(i3) ≡ Interval{:open,:closed}(i3) ∪ i1 ≡ d
    @test i1 ∪ Interval{:closed,:open}(i3) ≡ Interval{:closed,:open}(i3) ∪ i1 ≡ Interval{:closed,:open}(d)
    @test i1 ∪ OpenInterval(i3) ≡ OpenInterval(i3) ∪ i1 ≡ Interval{:closed,:open}(d)
    @test OpenInterval(i1) ∪ i3 ≡ i3 ∪ OpenInterval(i1) ≡ Interval{:open,:closed}(d)
    @test OpenInterval(i1) ∪ Interval{:open,:closed}(i3) ≡ Interval{:open,:closed}(i3) ∪ OpenInterval(i1) ≡ Interval{:open,:closed}(d)
    @test OpenInterval(i1) ∪ Interval{:closed,:open}(i3) ≡ Interval{:closed,:open}(i3) ∪ OpenInterval(i1) ≡ OpenInterval(d)
    @test Interval{:open,:closed}(i1) ∪ OpenInterval(i3) ≡ OpenInterval(i3) ∪ Interval{:open,:closed}(i1) ≡ OpenInterval(d)
    @test Interval{:open,:closed}(i1) ∪ Interval{:closed,:open}(i3) ≡ Interval{:closed,:open}(i3) ∪ Interval{:open,:closed}(i1) ≡ OpenInterval(d)

    # - intersection of partially overlapping intervals
    # i1      0 ------>------ 1
    # i3                 1/2 ------>------ 2
    d = one(T)/2 .. one(T)
    @test (@inferred i1 ∩ i3) ≡ (@inferred i3 ∩ i1) ≡ d
    @test Interval{:open,:closed}(i1) ∩ Interval{:open,:closed}(i3) ≡
            Interval{:open,:closed}(i3) ∩ Interval{:open,:closed}(i1) ≡ Interval{:open,:closed}(d)
    @test Interval{:closed,:open}(i1) ∩ Interval{:closed,:open}(i3) ≡
            Interval{:closed,:open}(i3) ∩ Interval{:closed,:open}(i1) ≡ Interval{:closed,:open}(d)
    @test OpenInterval(i1) ∩ OpenInterval(i3) ≡
            OpenInterval(i3) ∩ OpenInterval(i1) ≡ OpenInterval(d)
    @test i1 ∩ Interval{:open,:closed}(i3) ≡ Interval{:open,:closed}(i3) ∩ i1 ≡ Interval{:open,:closed}(d)
    @test i1 ∩ Interval{:closed,:open}(i3) ≡ Interval{:closed,:open}(i3) ∩ i1 ≡ d
    @test i1 ∩ OpenInterval(i3) ≡ OpenInterval(i3) ∩ i1 ≡ Interval{:open,:closed}(d)
    @test OpenInterval(i1) ∩ i3 ≡ i3 ∩ OpenInterval(i1) ≡ Interval{:closed,:open}(d)
    @test OpenInterval(i1) ∩ Interval{:open,:closed}(i3) ≡ Interval{:open,:closed}(i3) ∩ OpenInterval(i1) ≡ OpenInterval(d)
    @test OpenInterval(i1) ∩ Interval{:closed,:open}(i3) ≡ Interval{:closed,:open}(i3) ∩ OpenInterval(i1) ≡ Interval{:closed,:open}(d)
    @test Interval{:open,:closed}(i1) ∩ OpenInterval(i3) ≡ OpenInterval(i3) ∩ Interval{:open,:closed}(i1) ≡ Interval{:open,:closed}(d)
    @test Interval{:open,:closed}(i1) ∩ Interval{:closed,:open}(i3) ≡ Interval{:closed,:open}(i3) ∩ Interval{:open,:closed}(i1) ≡ d
    @test !isdisjoint(i1, i3)


    # - union of barely overlapping intervals
    # i2         1/3 ->- 1/2
    # i3                 1/2 ------>------ 2
    d = one(T)/3 .. 2*one(T)
    @test (@inferred i2 ∪ i3) ≡ (@inferred i3 ∪ i2) ≡ d
    @test Interval{:open,:closed}(i2) ∪ Interval{:open,:closed}(i3) ≡
            Interval{:open,:closed}(i3) ∪ Interval{:open,:closed}(i2) ≡ Interval{:open,:closed}(d)
    @test Interval{:closed,:open}(i2) ∪ Interval{:closed,:open}(i3) ≡
            Interval{:closed,:open}(i3) ∪ Interval{:closed,:open}(i2) ≡ Interval{:closed,:open}(d)
    @test_throws ArgumentError OpenInterval(i2) ∪ OpenInterval(i3)
    @test i2 ∪ Interval{:open,:closed}(i3) ≡ Interval{:open,:closed}(i3) ∪ i2 ≡ d
    @test i2 ∪ Interval{:closed,:open}(i3) ≡ Interval{:closed,:open}(i3) ∪ i2 ≡ Interval{:closed,:open}(d)
    @test i2 ∪ OpenInterval(i3) ≡ OpenInterval(i3) ∪ i2 ≡ Interval{:closed,:open}(d)
    @test OpenInterval(i2) ∪ i3 ≡ i3 ∪ OpenInterval(i2) ≡ Interval{:open,:closed}(d)
    @test_throws ArgumentError OpenInterval(i2) ∪ Interval{:open,:closed}(i3)
    @test Interval{:open,:closed}(i2) ∪ OpenInterval(i3) ≡ OpenInterval(i3) ∪ Interval{:open,:closed}(i2) ≡ OpenInterval(d)
    @test Interval{:open,:closed}(i2) ∪ Interval{:closed,:open}(i3) ≡ Interval{:closed,:open}(i3) ∪ Interval{:open,:closed}(i2) ≡ OpenInterval(d)

    # - intersection of barely overlapping intervals
    # i2         1/3 ->- 1/2
    # i3                 1/2 ------>------ 2
    d = one(T)/2 .. one(T)/2
    @test (@inferred i2 ∩ i3) ≡ (@inferred i3 ∩ i2) ≡ d
    @test Interval{:open,:closed}(i2) ∩ Interval{:open,:closed}(i3) ≡
            Interval{:open,:closed}(i3) ∩ Interval{:open,:closed}(i2) ≡ Interval{:open,:closed}(d)
    @test Interval{:closed,:open}(i2) ∩ Interval{:closed,:open}(i3) ≡
            Interval{:closed,:open}(i3) ∩ Interval{:closed,:open}(i2) ≡ Interval{:closed,:open}(d)
    @test OpenInterval(i2) ∩ OpenInterval(i3) ≡
            OpenInterval(i3) ∩ OpenInterval(i2) ≡ OpenInterval(d)
    @test i2 ∩ Interval{:open,:closed}(i3) ≡ Interval{:open,:closed}(i3) ∩ i2 ≡ Interval{:open,:closed}(d)
    @test i2 ∩ Interval{:closed,:open}(i3) ≡ Interval{:closed,:open}(i3) ∩ i2 ≡ d
    @test i2 ∩ OpenInterval(i3) ≡ OpenInterval(i3) ∩ i2 ≡ Interval{:open,:closed}(d)
    @test OpenInterval(i2) ∩ i3 ≡ i3 ∩ OpenInterval(i2) ≡ Interval{:closed,:open}(d)
    @test OpenInterval(i2) ∩ Interval{:open,:closed}(i3) ≡ Interval{:open,:closed}(i3) ∩ OpenInterval(i2) ≡ OpenInterval(d)
    @test OpenInterval(i2) ∩ Interval{:closed,:open}(i3) ≡ Interval{:closed,:open}(i3) ∩ OpenInterval(i2) ≡ Interval{:closed,:open}(d)
    @test Interval{:open,:closed}(i2) ∩ OpenInterval(i3) ≡ OpenInterval(i3) ∩ Interval{:open,:closed}(i2) ≡ Interval{:open,:closed}(d)
    @test Interval{:open,:closed}(i2) ∩ Interval{:closed,:open}(i3) ≡ Interval{:closed,:open}(i3) ∩ Interval{:open,:closed}(i2) ≡ d

    # - intersection of custom intervals
    @test intersect(MyUnitInterval(true,true), MyUnitInterval(false,false)) == OpenInterval(0,1)
    @test intersect(MyUnitInterval(true,true), OpenInterval(0,1)) == OpenInterval(0,1)

    # - union of non-overlapping intervals
    # i1      0 ------>------ 1
    # i4                                   2 -->-- 3
    @test_throws ArgumentError i1 ∪ i4
    @test_throws ArgumentError i4 ∪ i1
    @test_throws ArgumentError OpenInterval(i1) ∪ i4
    @test_throws ArgumentError i1 ∪ OpenInterval(i4)
    @test_throws ArgumentError Interval{:closed,:open}(i1) ∪ i4
    @test_throws ArgumentError Interval{:closed,:open}(i1) ∪ OpenInterval(i4)

    # - union of almost-overlapping intervals
    # i1      0 ------>------ 1
    # i5                        1.0+ -->-- 2
    @test_throws ArgumentError i1 ∪ i5
    @test_throws ArgumentError i5 ∪ i1
    @test_throws ArgumentError OpenInterval(i1) ∪ i5
    @test_throws ArgumentError i1 ∪ OpenInterval(i5)
    @test_throws ArgumentError Interval{:closed,:open}(i1) ∪ i5
    @test_throws ArgumentError Interval{:closed,:open}(i1) ∪ OpenInterval(i5)

    # - intersection of non-overlapping intervals
    # i1      0 ------>------ 1
    # i4                                   2 -->-- 3
    @test isempty(i1 ∩ i4)
    @test isempty(i4 ∩ i1)
    @test isempty(OpenInterval(i1) ∩ i4)
    @test isempty(i1 ∩ OpenInterval(i4))
    @test isempty(Interval{:closed,:open}(i1) ∩ i4)
    @test isdisjoint(i1, i4)
    @test isdisjoint(i4, i1)
    @test isdisjoint(OpenInterval(i1), i4)
    @test isdisjoint(i1, OpenInterval(i4))
    @test isdisjoint(Interval{:closed,:open}(i1), i4)


    # - intersection of almost-overlapping intervals
    # i1      0 ------>------ 1
    # i5                        1.0+ -->-- 2
    @test isempty(i1 ∩ i5)
    @test isempty(i5 ∩ i1)
    @test isempty(OpenInterval(i1) ∩ i5)
    @test isempty(i1 ∩ OpenInterval(i5))
    @test isempty(Interval{:closed,:open}(i1) ∩ i5)
    @test isdisjoint(i1, i5)
    @test isdisjoint(i5, i1)
    @test isdisjoint(OpenInterval(i1), i5)
    @test isdisjoint(i1, OpenInterval(i5))
    @test isdisjoint(Interval{:closed,:open}(i1), i5)

    # - union of interval with empty
    # i1      0 ------>------ 1
    # i_empty 0 ------<------ 1
    @test i1 ∪ i_empty ≡ i_empty ∪ i1 ≡ i1
    @test Interval{:open,:closed}(i1) ∪ Interval{:open,:closed}(i_empty) ≡
            Interval{:open,:closed}(i_empty) ∪ Interval{:open,:closed}(i1) ≡ Interval{:open,:closed}(i1)
    @test Interval{:closed,:open}(i1) ∪ Interval{:closed,:open}(i_empty) ≡
            Interval{:closed,:open}(i_empty) ∪ Interval{:closed,:open}(i1) ≡ Interval{:closed,:open}(i1)
    @test OpenInterval(i1) ∪ OpenInterval(i_empty) ≡
            OpenInterval(i_empty) ∪ OpenInterval(i1) ≡ OpenInterval(i1)
    @test i1 ∪ Interval{:open,:closed}(i_empty) ≡ Interval{:open,:closed}(i_empty) ∪ i1 ≡ i1
    @test i1 ∪ Interval{:closed,:open}(i_empty) ≡ Interval{:closed,:open}(i_empty) ∪ i1 ≡ i1
    @test i1 ∪ OpenInterval(i_empty) ≡ OpenInterval(i_empty) ∪ i1 ≡ i1
    @test OpenInterval(i1) ∪ i_empty ≡ i_empty ∪ OpenInterval(i1) ≡ OpenInterval(i1)
    @test OpenInterval(i1) ∪ Interval{:open,:closed}(i_empty) ≡ Interval{:open,:closed}(i_empty) ∪ OpenInterval(i1) ≡ OpenInterval(i1)
    @test OpenInterval(i1) ∪ Interval{:closed,:open}(i_empty) ≡ Interval{:closed,:open}(i_empty) ∪ OpenInterval(i1) ≡ OpenInterval(i1)
    @test Interval{:open,:closed}(i1) ∪ OpenInterval(i_empty) ≡ OpenInterval(i_empty) ∪ Interval{:open,:closed}(i1) ≡ Interval{:open,:closed}(i1)
    @test Interval{:open,:closed}(i1) ∪ Interval{:closed,:open}(i_empty) ≡ Interval{:closed,:open}(i_empty) ∪ Interval{:open,:closed}(i1) ≡ Interval{:open,:closed}(i1)

    # - intersection of interval with empty
    # i1      0 ------>------ 1
    # i_empty 0 ------<------ 1
    @test isempty(i1 ∩ i_empty)
    @test isempty(i_empty ∩ i1)
    @test isempty(OpenInterval(i1) ∩ i_empty)
    @test isempty(i1 ∩ OpenInterval(i_empty))
    @test isempty(Interval{:closed,:open}(i1) ∩ i_empty)
    @test isdisjoint(i1, i_empty)
    @test isdisjoint(i_empty, i1)
    @test isdisjoint(OpenInterval(i1), i_empty)
    @test isdisjoint(i1, OpenInterval(i_empty))
    @test isdisjoint(Interval{:closed,:open}(i1), i_empty)

    # - test matching endpoints
    @test (0..1) ∪ OpenInterval(0..1) ≡ OpenInterval(0..1) ∪ (0..1) ≡  0..1
    @test Interval{:open,:closed}(0..1) ∪ OpenInterval(0..1) ≡
            OpenInterval(0..1) ∪ Interval{:open,:closed}(0..1) ≡
            Interval{:open,:closed}(0..1)
    @test Interval{:closed,:open}(0..1) ∪ OpenInterval(0..1) ≡
            OpenInterval(0..1) ∪ Interval{:closed,:open}(0..1) ≡
            Interval{:closed,:open}(0..1)

    # - different interval types
    @test (1..2) ∩ OpenInterval(0.5, 1.5) ≡ Interval{:closed, :open}(1, 1.5)
    @test (1..2) ∪ OpenInterval(0.5, 1.5) ≡ Interval{:open, :closed}(0.5, 2)
end

@testset "in" begin
    @test in(0.1, 0.0..1.0) == true
    @test in(0.0, 0.0..1.0) == true
    @test in(1.1, 0.0..1.0) == false
    @test in(0.0, nextfloat(0.0)..1.0) == false

    @testset "missing in" begin
        @test ismissing(missing in 0..1)
        @test !(missing in 1..0)
        @test ismissing(missing in OpenInterval(0, 1))
        @test ismissing(missing in Interval{:closed, :open}(0, 1))
        @test ismissing(missing in Interval{:open, :closed}(0, 1))
    end

    @testset "complex in" begin
        @test 0+im ∉ 0..2
        @test 0+0im ∈ 0..2
        @test 0+eps()im ∉ 0..2

        @test 0+im ∉ OpenInterval(0,2)
        @test 0+0im ∉ OpenInterval(0,2)
        @test 1+0im ∈ OpenInterval(0,2)
        @test 1+eps()im ∉ OpenInterval(0,2)

        @test 0+im ∉ Interval{:closed,:open}(0,2)
        @test 0+0im ∈ Interval{:closed,:open}(0,2)
        @test 1+0im ∈ Interval{:closed,:open}(0,2)
        @test 1+eps()im ∉ Interval{:closed,:open}(0,2)

        @test 0+im ∉ Interval{:open,:closed}(0,2)
        @test 0+0im ∉ Interval{:open,:closed}(0,2)
        @test 1+0im ∈ Interval{:open,:closed}(0,2)
        @test 1+eps()im ∉ Interval{:open,:closed}(0,2)
    end
end

@testset "issubset" begin
    I = 0..3
    J = 1..2
    @test J ⊆ I
    @test I ⊈ J
    @test OpenInterval(J) ⊆ I
    @test OpenInterval(I) ⊈ J
    @test J ⊆ OpenInterval(I)
    @test I ⊈ OpenInterval(J)
    @test OpenInterval(J) ⊆ OpenInterval(I)
    @test OpenInterval(I) ⊈ OpenInterval(J)
    @test Interval{:closed,:open}(J) ⊆ OpenInterval(I)
    @test Interval{:open,:closed}(J) ⊆ OpenInterval(I)
    @test Interval{:open,:closed}(J) ⊆ Interval{:open,:closed}(I)
    @test OpenInterval(I) ⊈ OpenInterval(J)

    @test Interval{:closed,:open}(J) ⊆ I
    @test I ⊈ Interval{:closed,:open}(J)

    @test I ⊆ I
    @test OpenInterval(I) ⊆ I
    @test Interval{:open,:closed}(I) ⊆ I
    @test Interval{:closed,:open}(I) ⊆ I
    @test I ⊈ OpenInterval(I)
    @test I ⊈ Interval{:open,:closed}(I)
    @test I ⊈ Interval{:closed,:open}(I)

    @test Interval{:closed,:open}(I) ⊆ Interval{:closed,:open}(I)
    @test Interval{:open,:closed}(I) ⊈ Interval{:closed,:open}(I)

    @test !isequal(I, OpenInterval(I))
    @test !(I == OpenInterval(I))

    @test issubset(Interval{:closed,:closed}(1,2), Interval{:closed,:closed}(1,2)) == true
    @test issubset(Interval{:closed,:closed}(1,2), Interval{:open  ,:open  }(1,2)) == false
    @test issubset(Interval{:closed,:open  }(1,2), Interval{:open  ,:open  }(1,2)) == false
    @test issubset(Interval{:open  ,:closed}(1,2), Interval{:open  ,:open  }(1,2)) == false
    @test issubset(Interval{:closed,:closed}(1,2), Interval{:closed,:closed}(1,prevfloat(2.0))) == false
    @test issubset(Interval{:closed,:open  }(1,2), Interval{:open  ,:open  }(prevfloat(1.0),2)) == true
end

@testset "empty intervals" begin
    for T in (Float32,Float64)
        @test isempty(Interval{:open,:open}(zero(T),zero(T)))
        @test zero(T) ∉ Interval{:open,:open}(zero(T),zero(T))
        @test isempty(Interval{:open,:closed}(zero(T),zero(T)))
        @test zero(T) ∉ Interval{:open,:closed}(zero(T),zero(T))
        @test isempty(Interval{:closed,:open}(zero(T),zero(T)))
        @test zero(T) ∉ Interval{:closed,:open}(zero(T),zero(T))
    end
end
