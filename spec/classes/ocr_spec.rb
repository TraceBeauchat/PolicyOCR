# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ocr do
  describe '.valid?' do
    subject { described_class.new(representation).valid? }

    context 'when representation does not contain 4 subarrays' do
      let(:representation) { [] }

      it 'throws an exception' do
        expect { subject }.to raise_error(StandardError, 'Invalid OCR')
      end
    end

    context 'when representation has a subarray with less than 9 strings' do
      let(:representation) do
        [
          ['   ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ '],
          ['|_|', '|_ ', '  |', '|_ ', '| |', '|_|', '| |', '| |'],
          ['  |', ' _|', '  |', ' _|', '|_|', '|_|', '|_|', '|_|', '|_|'],
          ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ']
        ]
      end

      it 'throws an exception' do
        expect { subject }.to raise_error(StandardError, 'Invalid OCR')
      end
    end

    context 'when representation contains a character other than space, |, or _' do
      let(:representation) do
        [
          ['   ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ '],
          ['|_|', '|_ ', '  |', '|_ ', '| |', '|_|', '| |', '| |', '| |'],
          ['  |', ' _|', '  |', ' _|', '|_|', '|_|', '|_|', '|_|', '|_|'],
          ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', ' a ']
        ]
      end

      it 'throws an exception' do
        expect { subject }.to raise_error(StandardError, 'Invalid OCR')
      end
    end

    context 'when the representation contains a string with less than 3 characters' do
      let(:representation) do
        [
          ['   ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ '],
          ['|_|', '|_ ', '  |', '|_ ', '| |', '|_|', '| |', '| |', '||'],
          ['  |', ' _|', '  |', ' _|', '|_|', '|_|', '|_|', '|_|', '|_|'],
          ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ']
        ]
      end

      it 'throws an exception' do
        expect { subject }.to raise_error(StandardError, 'Invalid OCR')
      end
    end

    context 'when the representation is valid' do
      let(:representation) do
        [
          ['   ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ '],
          ['|_|', '|_ ', '  |', '|_ ', '| |', '|_|', '| |', '| |', '| |'],
          ['  |', ' _|', '  |', ' _|', '|_|', '|_|', '|_|', '|_|', '|_|'],
          ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ']
        ]
      end

      it 'throws an exception' do
        expect { subject }.not_to raise_error
      end
    end
  end

  describe '.to_s' do
    subject { described_class.new(representation).to_s }

    context 'when all digits are recognizable' do
      let(:representation) do
        [
          ['   ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ '],
          ['|_|', '|_ ', '  |', '|_ ', '| |', '|_|', '| |', '| |', '| |'],
          ['  |', ' _|', '  |', ' _|', '|_|', '|_|', '|_|', '|_|', '|_|'],
          ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ']
        ]
      end

      it 'returns a string of 9 numbers' do
        result = subject

        expect(result.length).to eql 9
        expect(result.match(/\d{9}/)).not_to be_nil
      end
    end

    context 'when a digit is not recognizable' do
      let(:representation) do
        [
          ['   ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ '],
          [' _|', '|_ ', '  |', '|_ ', '| |', '|_|', '| |', '| |', '| |'],
          ['  |', ' _|', '  |', ' _|', '|_|', '|_|', '|_|', '|_|', '|_|'],
          ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ']
        ]
      end

      it 'returns a string of 9 characters with question marks' do
        result = subject

        expect(result.length).to eql 9
        expect(result.match(/[\d?]{9}/)).not_to be_nil
        expect(result).to include('?')
      end
    end
  end
end
