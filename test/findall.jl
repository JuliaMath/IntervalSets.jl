# Helper function to test that findall(in(interval), x) works. By
# default, a reference is generated using the general algorithm,
# linear in complexity, by generating a vector with the same contents
# as x.
function assert_in_interval(x, interval,
                            reference=findall(v -> v ∈ interval, collect(x)))
    res = findall(in(interval), x)
    @test res == reference || isempty(res) && isempty(reference)
end

@testset "Interval coverage" begin
    x = range(0, stop=1, length=21)

    @testset "Two intervals" begin
        assert_in_interval(x, 0..0.5, 1:11)
        assert_in_interval(x, 0..0.5)
        assert_in_interval(x, Interval{:closed,:open}(0,0.5), 1:10)
        assert_in_interval(x, Interval{:closed,:open}(0,0.5))
        assert_in_interval(x, Interval{:closed,:open}(0.25,0.5), 6:10)
        assert_in_interval(x, Interval{:closed,:open}(0.25,0.5))
    end

    @testset "Three intervals" begin
        assert_in_interval(x, Interval{:closed,:open}(0,1/3), 1:7)
        assert_in_interval(x, Interval{:closed,:open}(1/3,2/3), 8:14)
        assert_in_interval(x, 2/3..1, 15:21)
    end

    @testset "Open interval" begin
        assert_in_interval(x, OpenInterval(0.2,0.4), 6:8)
    end

    @testset "Random intervals" begin
        @testset "L=$L" for L=[:closed,:open]
            @testset "R=$R" for R=[:closed,:open]
                for i = 1:1 # 20
                    interval = Interval{L,R}(minmax(rand(),rand())...)
                    assert_in_interval(x, interval)
                end
            end
        end
    end

    @testset "Interval containing one point" begin
        @testset "L=$L" for L=[:closed,:open]
            @testset "R=$R" for R=[:closed,:open]
                interval = Interval{L,R}(0.4619303378979984,0.5450937144417902)
                assert_in_interval(x, interval)
            end
        end
    end

    @testset "Interval containing no points" begin
        @testset "L=$L" for L=[:closed,:open]
            @testset "R=$R" for R=[:closed,:open]
                interval = Interval{L,R}(0.9072957410215778,0.9082803807133988)
                assert_in_interval(x, interval)
            end
        end

    end

    @testset "Large intervals" begin
        @test findall(in(4..Inf), 2:2:10) == 2:5
        @test findall(in(4..1e20), 2:2:10) == 2:5
        @test isempty(findall(in(-Inf..(-1e20)), 2:2:10))
    end

    @testset "Reverse intervals" begin
        for x in [1:10, 1:3:10, 2:3:11, -1:9, -2:0.5:5]
            for lo in -3:4, hi in 5:13
                for L in [:closed, :open], R in [:closed, :open]
                    int = Interval{L,R}(lo,hi)
                    @test findall(in(int), x) == findall(i -> x[i] in int, eachindex(x))
                    r = reverse(x)
                    @test findall(in(int), r) == findall(i -> r[i] in int, eachindex(r))
                end
            end
        end
    end

    @testset "Arrays" begin
        @test findall(in(1..6), collect(0:7)) == 2:7
        @test findall(in(1..6), reshape(1:16, 4, 4)) ==
            vcat([CartesianIndex(i,1) for i = 1:4], CartesianIndex(1,2), CartesianIndex(2,2))
    end
end
