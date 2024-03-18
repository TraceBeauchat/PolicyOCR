# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PolicyOcr do
  let(:service) { PolicyOcr.new(filename:) }

  describe '.call' do
    subject { service.send(:call) }

    context 'when called with a valid file' do
      let(:filename) { File.join(file_fixture_path, 'sample.txt') }

      it 'returns an array of PolicyNumber(s)' do
        result = subject
        expect(result).to be_a Array

        result.each do |element|
          expect(element).to be_a PolicyNumber
        end
      end
    end

    context 'when called with an invalid file' do
      let(:filename) { File.join(file_fixture_path, 'with_illegal_characters.txt') }

      it 'throws an exception' do
        expect { subject }.to raise_error(StandardError)
      end
    end
  end

  describe '.load_file' do
    subject { service.send :load_file }

    context 'when the file does not exist' do
      let(:filename) { 'sample.txt' }

      it 'throws an exception' do
        expect { subject }.to raise_error(StandardError, /Could not find/)
      end
    end

    context 'when the file exists' do
      context 'when file contains lines with less than 27 characters per line' do
        let(:filename) { File.join(file_fixture_path, 'with_short_line.txt') }

        it 'throws and exception' do
          expect { subject }.to raise_error(StandardError, /line length/)
        end
      end

      context 'when file contains illegal characters' do
        let(:filename) { File.join(file_fixture_path, 'with_illegal_characters.txt') }

        it 'throws and exception' do
          expect { subject }.to raise_error(StandardError, /invalid character/)
        end
      end

      context 'when the file is valid' do
        let(:filename) { File.join(file_fixture_path, 'sample.txt') }

        it 'properly parses the file' do
          lines = subject

          # sample.txt contains 44 lines
          expect(lines.length).to eql 44

          # policy numbers contain 9 digits, so each line array should contain 9 sub-elements (1 for each digit)
          lines.each do |line|
            expect(line.length).to eql 9

            line.each do |digit|
              # Each digit is made up of 3 characters
              expect(digit.length).to eql 3

              # Only space, |, and _ are legal characters
              expect(digit.match(/[\s|_]{3}/)).not_to be_nil
            end
          end
        end
      end
    end
  end

  describe '.fetch_next_policy_number' do
    subject { service.send :fetch_next_policy_number }

    let(:filename) {File.join(file_fixture_path, 'sample.txt') }

    before :each do
      service.instance_variable_set(:@lines, service.send(:load_file))
    end

    context 'when called' do
      context 'when there are lines left' do
        it 'removes 4 lines' do
          expect { subject }.to change { service.instance_variable_get(:@lines).length }.by -4
        end
      end

      context 'when there are no lines left' do
        before do
          service.instance_variable_get(:@lines).clear
        end

        it 'does not remove any lines' do
          expect { subject }.to change { service.instance_variable_get(:@lines).length }.by 0
        end
      end
    end
  end

  describe '.policy_number' do
    subject { service.send(:policy_number, policy_ocr) }

    let(:filename) {File.join(file_fixture_path, 'sample.txt') }

    context 'when an invalid number is provided' do
      let(:digits) { ['a', 1, 2, 3, 4, 5, 6, 7, 8] }
      let(:policy_ocr) { nil }

      it 'throws an exception' do
        expect { subject }.to raise_error(StandardError)
      end
    end

    context 'when a valid number is provided' do
      let(:digits) { [4, 5, 7, 5, 0, 8, 0, 0, 0] }
      let(:policy_ocr) do
        [
          ['   ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ '],
          ['|_|', '|_ ', '  |', '|_ ', '| |', '|_|', '| |', '| |', '| |'],
          ['  |', ' _|', '  |', ' _|', '|_|', '|_|', '|_|', '|_|', '|_|'],
          ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ']
        ]
      end

      it 'returns a PolicyNumber' do
        expect(subject).to be_a PolicyNumber
      end
    end
  end
end
