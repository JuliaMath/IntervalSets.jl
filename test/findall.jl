using OffsetArrays
using Unitful

# Helper function to test that findall(in(interval), x) works. By
# default, a reference is generated using the general algorithm,
# linear in complexity, by generating a vector with the same contents
# as x.
function assert_in_interval(x, interval,
                            expected=findall(v -> v ∈ interval, x))

    result = :(findall(in($interval), $x))
    expr = :($result == $expected || isempty($result) && isempty($expected))
    if !(@eval $expr)
        println("Looking for elements of $x ∈ $interval, got $(@eval $result), expected $expected")
        length(x) < 30 && println("    x = ", collect(pairs(x)), "\n")
    end
    @eval @test $expr
end

@testset "Interval coverage" begin
    @testset "Basic tests" begin
        let x = range(0, stop=1, length=21)
            Random.seed!(321)
            @testset "$kind" for (kind,end_points) in [
                ("Two intervals", [(0.0, 0.5), (0.25,0.5)]),
                ("Three intervals", [(0, 1/3), (1/3, 2/3), (2/3, 1)]),
                ("Random intervals", [minmax(rand(),rand()) for i = 1:2]),
                ("Interval containing one point", [(0.4619303378979984,0.5450937144417902)]),
                ("Interval containing no points", [(0.9072957410215778,0.9082803807133988)])
            ]
                @testset "L=$L" for L=[:closed,:open]
                    @testset "R=$R" for R=[:closed,:open]
                        for (a,b) in end_points
                            interval = Interval{L,R}(a, b)
                            @testset "Reversed: $reversed" for reversed in [false, true]
                                assert_in_interval(reversed ? reverse(x) : x, interval)
                            end
                        end
                    end
                end
            end

            @testset "Open interval" begin
                assert_in_interval(x, OpenInterval(0.2,0.4), 6:8)
            end
        end
    end

    @testset "Partially covered intervals" begin
        @testset "$T" for T in (Float32,Float64,BigFloat)
            @testset "$name, x = $x" for (name,x) in [
                ("Outside left",range(T(-1),stop=T(-0.5),length=10)),
                ("Touching left",range(T(-1),stop=T(0),length=10)),
                ("Touching left-ϵ",range(T(-1),stop=T(0)-eps(T),length=10)),
                ("Touching left+ϵ",range(T(-1),stop=T(0)+eps(T),length=10)),

                ("Outside right",range(T(1.5),stop=T(2),length=10)),
                ("Touching right",range(T(1),stop=T(2),length=10)),
                ("Touching right-ϵ",range(T(1)-eps(T),stop=T(2),length=10)),
                ("Touching right+ϵ",range(T(1)+eps(T),stop=T(2),length=10)),

                ("Other right",range(T(0.5),stop=T(1),length=10)),
                ("Other right-ϵ",range(T(0.5)-eps(T(0.5)),stop=T(1),length=10)),
                ("Other right+ϵ",range(T(0.5)+eps(T(0.5)),stop=T(1),length=10)),

                ("Complete", range(T(0),stop=T(1),length=10)),
                ("Complete-ϵ", range(eps(T),stop=T(1)-eps(T),length=10)),
                ("Complete+ϵ", range(-eps(T),stop=T(1)+eps(T),length=10)),

                ("Left partial", range(T(-0.5),stop=T(0.6),length=10)),
                ("Left", range(T(-0.5),stop=T(1.0),length=10)),
                ("Right partial", range(T(0.5),stop=T(1.6),length=10)),
                ("Right", range(T(0),stop=T(1.6),length=10))]
                @testset "L=$L" for L=[:closed,:open]
                    @testset "R=$R" for R=[:closed,:open]
                        @testset "Reversed: $reversed" for reversed in [false, true]
                            for (a,b) in [(T(0.0),T(0.5)),(T(0.5),T(1.0))]
                                interval = Interval{L,R}(a, b)
                                assert_in_interval(reversed ? reverse(x) : x, interval)
                            end
                        end
                    end
                end
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
                    interval = Interval{L,R}(lo,hi)
                    assert_in_interval(x, interval)
                    assert_in_interval(reverse(x), interval)
                end
            end
        end
    end

    @testset "Arrays" begin
        @test findall(in(1..6), collect(0:7)) == 2:7
        @test findall(in(1..6), reshape(1:16, 4, 4)) ==
            vcat([CartesianIndex(i,1) for i = 1:4], CartesianIndex(1,2), CartesianIndex(2,2))
    end

    @testset "Empty ranges and intervals" begin
        # Range empty
        @test isempty(findall(in(1..6), 1:0))
        # Interval empty
        @test isempty(findall(in(Interval{:closed,:open}(1.0..1.0)),
                              0.0:0.02040816326530612:1.0))
    end

    @testset "Offset arrays" begin
        for (x,interval) in [(OffsetArray(ones(10), -5), -1..1),
                             (OffsetArray(1:5, -3), 2..4),
                             (OffsetArray(5:-1:1, -5), 2..4)]
            assert_in_interval(x, interval)
            assert_in_interval(reverse(x), interval)
        end
    end

    @testset "Units, dates" begin
        for (x, interval) in [
            ([-2u"m", 3u"m"], -1u"m"..1u"m"),
            ([-2u"m", 0u"m", 1u"m"], -1u"m"..1u"m"),
            (-2u"m":10u"m":50u"m", -1u"m"..1u"m"),
            (-2u"m":1u"m":1u"m", -1u"m"..1u"m"),
            (-2u"km":1u"cm":1u"km", -1u"m"..1u"m"),
            (-2u"km":1u"cm":1u"km", -1u"m"..1u"km"),
            (-2u"km":0.1u"m":1u"km", -1u"m"..1u"km"),
            (-2u"m":0.1u"m":1u"m", -1.05u"m"..1u"km"),
            (-2u"m":0.1u"m":1u"m", -4u"m"..1u"km"),
            (-2u"m":0.1u"m":1u"m", -4.05u"m"..1u"km"),
            (DateTime(2021, 1, 1):Millisecond(10000):DateTime(2021, 3, 1), DateTime(2020, 1, 11)..DateTime(2020, 2, 22)),
            (DateTime(2021, 1, 1):Millisecond(10000):DateTime(2021, 3, 1), DateTime(2021, 1, 11)..DateTime(2021, 2, 22)),
        ]
            assert_in_interval(x, interval)
            assert_in_interval(reverse(x), interval)
        end
    end
end
