# frozen_string_literal: true

# This service parses a file containing the OCR representations of policy numbers.
#
# A file contains a number of entries which each look like this:
#     _  _     _  _  _  _  _
#   | _| _||_||_ |_   ||_||_|
#   ||_  _|  | _||_|  ||_||_|
#
# Each entry is 4 lines long, and each line has 27 characters. The first 3 lines of each entry contain
# a policy number written using pipes and underscores, and the fourth line is blank. Each policy number
# should have 9 digits, all of which should be in the range 0-9.
class PolicyOcr < ApplicationService
  def initialize(filename:)
    super

    @filename = filename
    @lines = []

    raise StandardError, "Could not find #{@filename}" unless File.exist?(@filename)
  end

  def call
    @lines = load_file
    return [] if @lines.empty?

    policy_numbers = []
    until @lines.empty?
      policy_ocr = fetch_next_policy_number
      break if policy_ocr.empty? # Did we receive the ocr for a policy number?

      policy_numbers << policy_number(policy_ocr)
    end

    policy_numbers
  end

  private

  # Reads the lines of the file (without the EOL character), and splits each line
  # into an array containing the characters for each digit in the given line.
  #
  # NOTE: For large files we would want to stream the file, read 4 lines, process the 4 lines, and continue.
  def load_file
    File.readlines(@filename, chomp: true).each_with_index.map do |line, index|
      # Validate the format of the line
      raise StandardError, "Line #{index + 1}: Invalid file format (line length)" if line.length != 27
      raise StandardError, "Line #{index + 1}: Invalid file format (invalid character)" if line.match(/[\s|_]{27}/).nil?

      # Split the line into its digit pieces (sequence of 3 |, _, or space)
      line.scan(/.{3}/)
    end
  end

  # Removes and returns the array elements representing the next policy number to parse
  def fetch_next_policy_number
    @lines.shift(4)
  end

  # Build the policy number specified by the given digits
  def policy_number(policy_ocr)
    ocr = Ocr.new(policy_ocr)
    PolicyNumber.new(ocr.to_s, ocr: ocr)
  end
end
