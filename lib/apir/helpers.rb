# Get difference between two dates
#
# @param [Date] time_from
# @param [Date] time_to
# @return [Float] difference between from-to
def time_from(time_from='', time_to='')
  dif = time_to - time_from
  (dif * 1000).round
end
