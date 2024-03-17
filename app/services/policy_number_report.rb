# frozen_string_literal: true

# This service creates a report of the policy number validities
#
# The file has one policy number per row. If some characters are illegible,
# they are replaced by a ?. In the case of a wrong checksum (ERR), or
# illegible number (ILL), this is noted in a second column indicating status.
#
# Example:
# 457508000
# 664371495 ERR
# 86110??36 ILL
class PolicyNumberReport < ApplicationService
  def initialize(policy_numbers:, filename:)
    super

    @policy_numbers = policy_numbers
    @filename = filename
  end

  def call
    File.open(@filename, 'w') do |file|
      @policy_numbers.each do |policy_number|
        file.puts "#{policy_number.number} #{policy_number.status}"
      end
    end
  end
end
