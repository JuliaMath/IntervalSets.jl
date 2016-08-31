using IntervalSets
using Base.Test

@testset "IntervalSets" begin
    io = IOBuffer()
    @test ordered(2, 1) == (1, 2)
    @test ordered(1, 2) == (1, 2)
    @test ordered(Float16(1), 2) == (1, 2)

    @testset "Closed Sets" begin
        I = 0..3
        print(io, I)
        @test String(io) == "0..3"
        J = 3..2
        K = 5..4
        L = 3 ± 2
        M = ClosedInterval(2, 5.0)
        takebuf_array(io)
        print(io, M)
        @test String(io) == "2.0..5.0"
        N = ClosedInterval(UInt8(255), 300)
        O = CartesianIndex(1, 2, 3, 4) ± 2
        @test O == (-1..3, 0..4, 1..5, 2..6)

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

        @test 2 in I

        @test I ∪ L == ClosedInterval(0, 5)
        @test I ∩ L == ClosedInterval(1, 3)
        @test isempty(J ∩ K)
        @test isempty((2..5) ∩ (7..10))
        @test isempty((1..10) ∩ (7..2))
        A = Float16(1.1)..Float16(1.234)
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
    end
end
