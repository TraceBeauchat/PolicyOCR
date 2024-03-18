# frozen_string_literal: true

# A policy number is represented as a string containing 9 digits
class PolicyNumber
  BLANK_LINE = "#{' ' * 27}\n".freeze

  attr_reader :number, :ocr

  def initialize(number, ocr:nil)
    @number = number
    @ocr = ocr

    raise StandardError, "Invalid policy number format: #{@number}" unless format_valid?
    raise StandardError, 'Invalid OCR' unless @ocr.nil? || @ocr.valid?
  end

  # A valid policy number is indicated by its checksum equaling 0
  def valid?
    !@number.include?('?') && checksum.zero?
  end

  # Maps a policy number to its status string:
  # * ILL (ILLEGIBLE) if the number contains one ore more ?'s
  # * ERR (ERROR) if the number's checksum is not valid
  # * nil if the number is valid
  def status
    if @number.include?('?')
      'ILL'
    elsif !valid?
      'ERR'
    end
  end

  private

  # Verifies that the string is a properly formatted policy number
  #  * Length = 9
  #  * Only contains digits or ?'s'
  def format_valid?
    !@number.match(/[\d?]{9}/).nil? && @number.length == 9
  end

  # Calculates a checksum number for the policy number using:
  #
  # policy number:   3  4  5  8  8  2  8  6  5
  # position names: d9 d8 d7 d6 d5 d4 d3 d2 d1
  #
  # checksum calculation:
  # d1 + (2 * d2) + (3 * d3) + ... + (9 * d9)) mod 11
  def checksum
    @number.reverse.split('').each_with_index.reduce(0) do |acc, (digit, index)|
      acc + (index + 1) * digit.to_i
    end % 11
  end
end
