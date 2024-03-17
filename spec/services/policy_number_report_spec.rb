# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PolicyNumberReport do
  subject { described_class.call(policy_numbers:, filename:) }

  let(:policy_numbers) do
    [
      PolicyNumber.new(
        '457508000',
        ocr: [
          ["   ", " _ ", " _ ", " _ ", " _ ", " _ ", " _ ", " _ ", " _ "],
          ["|_|", "|_ ", "  |", "|_ ", "| |", "|_|", "| |", "| |", "| |"],
          ["  |", " _|", "  |", " _|", "|_|", "|_|", "|_|", "|_|", "|_|"],
          ["   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   "]
        ]
      ),
      PolicyNumber.new(
        '123456789',
        ocr: [
          ["   ", " _ ", " _ ", "   ", " _ ", " _ ", " _ ", " _ ", " _ "],
          ["  |", " _|", " _|", "|_|", "|_ ", "|_ ", "  |", "|_|", "|_|"],
          ["  |", "|_ ", " _|", "  |", " _|", "|_|", "  |", "|_|", " _|"],
          ["   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   "]
        ]
      ),
      PolicyNumber.new(
        '?23456789',
        ocr: [
          ["   ", " _ ", " _ ", "   ", " _ ", " _ ", " _ ", " _ ", " _ "],
          [" _|", " _|", " _|", "|_|", "|_ ", "|_ ", "  |", "|_|", "|_|"],
          ["  |", "|_ ", " _|", "  |", " _|", "|_|", "  |", "|_|", " _|"],
          ["   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   "]
        ]
      ),
      PolicyNumber.new(
        '123456788',
        ocr: [
          ["   ", " _ ", " _ ", "   ", " _ ", " _ ", " _ ", " _ ", " _ "],
          ["  |", " _|", " _|", "|_|", "|_ ", "|_ ", "  |", "|_|", "|_|"],
          ["  |", "|_ ", " _|", "  |", " _|", "|_|", "  |", "|_|", "|_|"],
          ["   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   "]
        ]
      )
    ]
  end

  let(:filename) { 'results.txt' }

  context 'when called' do
    before :each do
      subject
    end

    it 'creates the file' do
      expect(File.exist?(filename)).to be_truthy
    end

    it 'contains a line for each policy number' do
      expect(File.readlines(filename).count).to eql(4)
    end

    it 'is properly formatted' do
      File.readlines(filename, chomp: true).each do |line|
        number, status = line.split(' ')

        # Expect the column to be 9 characters 0-9, ?
        expect(number.match(/[\d?]{9}/)).not_to be_nil

        # Expect second column (status) to be ILL or ERR or nil
        expect(['ILL', 'ERR', nil]).to include(status)
      end
    end

    after :each do
      File.delete(filename)
    end
  end
end
