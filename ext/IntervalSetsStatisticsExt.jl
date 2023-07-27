module IntervalSetsStatisticsExt

using IntervalSets
using Statistics

Statistics.mean(d::AbstractInterval) = IntervalSets.mean(d)

end
