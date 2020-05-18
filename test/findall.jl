# Helper function to test that findall(in(interval), x) works. By
# default, a reference is generated using the general algorithm,
# linear in complexity, by generating a vector with the same contents
# as x.
function assert_in_interval(x, interval,
                            expected=eachindex(x)[findall(v -> v ∈ interval, collect(x))]
                            )

    result = :(findall(in($interval), $x))
    expr = :($result == $expected || isempty($result) && isempty($expected))
    if !(@eval $expr)
        println("Looking for elements of $x ∈ $interval, got $(@eval $result), expected $expected")
        length(x) < 30 && println("    x = ", collect(enumerate(x)), "\n")
    end
    @eval @test $expr
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

    Random.seed!(321)
    @testset "Random intervals" begin
        @testset "L=$L" for L=[:closed,:open]
            @testset "R=$R" for R=[:closed,:open]
                for i = 1:20
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
                    assert_in_interval(x, int)
                    r = reverse(x)
                    assert_in_interval(r, int)
                end
            end
        end
    end

    @testset "Arrays" begin
        @test findall(in(1..6), collect(0:7)) == 2:7
        @test findall(in(1..6), reshape(1:16, 4, 4)) ==
            vcat([CartesianIndex(i,1) for i = 1:4], CartesianIndex(1,2), CartesianIndex(2,2))
    end

    @testset "Corner case" begin
        @test isempty(findall(in(1..6), 1:0))
        @test isempty(findall(in(Interval{:closed,:open}(1.0..1.0)),
                              0.0:0.02040816326530612:1.0))
    end

    @testset "Compact support" begin
        a,b = 0,1
        x = range(a, stop=b, length=21)
        @testset "Interval coverage" begin
            @testset "Two intervals" begin
                @testset "Reversed: $reversed" for reversed in [false, true]
                    assert_in_interval(reversed ? reverse(x) : x, 0..0.5)
                end
                @testset "L=$L" for L=[:closed,:open]
                    @testset "R=$R" for R=[:closed,:open]
                        @testset "Reversed: $reversed" for reversed in [false, true]
                            assert_in_interval(reversed ? reverse(x) : x, Interval{L,R}(0,0.5))
                            assert_in_interval(reversed ? reverse(x) : x, Interval{L,R}(0.25,0.5))
                        end
                    end
                end
            end
            @testset "Three intervals" begin
                @testset "Reversed: $reversed" for reversed in [false, true]
                    assert_in_interval(reversed ? reverse(x) : x, Interval{:closed,:open}(0,1/3))
                    assert_in_interval(reversed ? reverse(x) : x, Interval{:closed,:open}(1/3,2/3))
                    assert_in_interval(reversed ? reverse(x) : x, 2/3..1)
                end
            end
            @testset "Open interval" begin
                @testset "Reversed: $reversed" for reversed in [false, true]
                    assert_in_interval(reversed ? reverse(x) : x, OpenInterval(0.2,0.4))
                end
            end
            @testset "Random intervals" begin
                Random.seed!(4321)
                @testset "L=$L" for L=[:closed,:open]
                    @testset "R=$R" for R=[:closed,:open]
                        @testset "Reversed: $reversed" for reversed in [false, true]
                            for i = 1:20
                                interval = Interval{L,R}(minmax(rand(),rand())...)
                                assert_in_interval(reversed ? reverse(x) : x, interval)
                            end
                        end
                    end
                end
            end
        end

        @testset "Partially covered intervals" begin
            @testset "$name, x = $x" for (name,x) in [
                ("Outside left",range(-1,stop=-0.5,length=10)),
                ("Touching left",range(-1,stop=0,length=10)),
                ("Touching left-ϵ",range(-1,stop=0-eps(),length=10)),
                ("Touching left+ϵ",range(-1,stop=0+eps(),length=10)),

                ("Outside right",range(1.5,stop=2,length=10)),
                ("Touching right",range(1,stop=2,length=10)),
                ("Touching right-ϵ",range(1-eps(),stop=2,length=10)),
                ("Touching right+ϵ",range(1+eps(),stop=2,length=10)),

                ("Other right",range(0.5,stop=1,length=10)),
                ("Other right-ϵ",range(0.5-eps(0.5),stop=1,length=10)),
                ("Other right+ϵ",range(0.5+eps(0.5),stop=1,length=10)),

                ("Complete", range(0,stop=1,length=10)),
                ("Complete-ϵ", range(eps(),stop=1-eps(),length=10)),
                ("Complete+ϵ", range(-eps(),stop=1+eps(),length=10)),

                ("Left partial", range(-0.5,stop=0.6,length=10)),
                ("Left", range(-0.5,stop=1.0,length=10)),
                ("Right partial", range(0.5,stop=1.6,length=10)),
                ("Right", range(0,stop=1.6,length=10))]
                @testset "L=$L" for L=[:closed,:open]
                    @testset "R=$R" for R=[:closed,:open]
                        @testset "Reversed: $reversed" for reversed in [false, true]
                            for (a,b) in [(0.0,0.5),(0.5,1.0)]
                                interval = Interval{L,R}(a, b)
                                assert_in_interval(reversed ? reverse(x) : x, interval)
                            end
                        end
                    end
                end
            end
        end
    end
end
