module IntervalSetsStatsBaseExt

using IntervalSets
using StatsBase

StatsBase.geomean(d::AbstractInterval) = sqrt(leftendpoint(d) * rightendpoint(d))

end
