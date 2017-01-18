# frozen_string_literal: true

# Get difference between two dates
#
# @param [Date] time_from
# @param [Date] time_to
# @return [Float] difference between from-to
def time_from(time_from='', time_to='')
  dif = time_to - time_from
  (dif * 1000).round
end

# https://github.com/rails/rails/blob/c0357d789b4323da64f1f9f82fa720ec9bac17cf/activesupport/lib/active_support/core_ext/hash/compact.rb#L17
class Hash
  # Returns a hash with non +nil+ values.
  #
  #   hash = { a: true, b: false, c: nil}
  #   hash.compact # => { a: true, b: false}
  #   hash # => { a: true, b: false, c: nil}
  #   { c: nil }.compact # => {}
  def compact
    self.select { |_, value| !value.nil? }
  end

  # Replaces current hash with non +nil+ values.
  #
  #   hash = { a: true, b: false, c: nil}
  #   hash.compact! # => { a: true, b: false}
  #   hash # => { a: true, b: false}
  def compact!
    self.reject! { |_, value| value.nil? }
  end
end