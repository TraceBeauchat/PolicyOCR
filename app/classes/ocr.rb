# frozen_string_literal: true

# This class represents and supports the parsing of an OCR array.
class Ocr
  include Digits

  BLANK_LINE = "#{' ' * 27}\n".freeze

  def initialize(ocr)
    @ocr = ocr

    raise StandardError, 'Invalid OCR' unless valid?
  end

  # Validates the ocr
  #  * Is an Array with 4 sub-arrays
  #  * Each line contains 9 strings
  #  * Each string is 3 characters [blank, _, or |]
  def valid?
    return false unless @ocr&.length == 4

    @ocr.all? { |line| ocr_line_valid?(line) }
  end

  def to_s
    parse_digits.join
  end

  # Format OCR for display
  def pretty_print_it
    @ocr.map do |line|
      line.join('')
    end.join("\n") + BLANK_LINE
  end

  private

  # A line in the OCR representation should be
  #  * Each line contains 9 strings
  #  * Each string is 3 characters [blank, _, or |]
  def ocr_line_valid?(line)
    return false unless line&.length == 9

    line.all? { |str| str.length == 3 && !str.match(/[\s|_]{3}/).nil? }
  end

  # Returns an array containing each digit in the policy number
  def parse_digits
    (0..8).map do |position|
      digit_ocr = digit_at(position)
      OCR_MAP[digit_ocr] || '?'
    end
  end

  # Plucks the string representing a complete digit at the specified position (0..8)
  def digit_at(position)
    raise StandardError, "Invalid position: #{position}" unless (0..8).include?(position)

    @ocr[0][position] + @ocr[1][position] + @ocr[2][position]
  end
end
