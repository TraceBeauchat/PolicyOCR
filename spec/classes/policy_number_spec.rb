# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PolicyNumber do
  describe '.new' do
    subject { described_class.new(number, ocr:) }

    context 'when the policy number does not contain 9 characters' do
      let(:number) { '0123456' }
      let(:ocr) { nil }

      it 'throws an exception' do
        expect{ subject }.to raise_error(StandardError, "Invalid policy number format: #{number}")
      end
    end

    context 'when the policy number contains invalid characters' do
      let(:number) { 'ab?123567' }
      let(:ocr) { nil }

      it 'throws an exception' do
        expect{ subject }.to raise_error(StandardError, "Invalid policy number format: #{number}")
      end
    end

    context 'when the policy number is valid' do
      let(:number) { '04?123567' }

      context 'when the OCR does not contain 4 rows' do
        let(:ocr) do
          [
            ['   ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ '],
            ['|_|', '|_ ', '  |', '|_ ', '| |', '|_|', '| |', '| |', '| |'],
            ['  |', ' _|', '  |', ' _|', '|_|', '|_|', '|_|', '|_|', '|_|'],
          ]
        end

        it 'throws an exception' do
          expect{ subject }.to raise_error(StandardError, 'Invalid OCR')
        end
      end

      context 'when an OCR line does not contain 9 strings' do
        let(:ocr) do
          [
            ['   ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ '],
            ['|_|', '|_ ', '  |', '|_ ', '| |', '|_|', '| |', '| |'],
            ['  |', ' _|', '  |', ' _|', '|_|', '|_|', '|_|', '|_|', '|_|'],
            ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ']
          ]
        end

        it 'throws an exception' do
          expect{ subject }.to raise_error(StandardError, 'Invalid OCR')
        end
      end

      context 'when an OCR string contains invalid characters' do
        let(:ocr) do
          [
            ['   ', ' _ ', ' _ ', ' a ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ '],
            ['|_|', '|_ ', '  |', '|_ ', '| |', '|_|', 'b |', '| |', '| |'],
            ['  |', ' _|', '  |', ' _|', '|_|', '|_|', '|_|', '|_|', '|_|'],
            ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ']
          ]
        end

        it 'throws an exception' do
          expect{ subject }.to raise_error(StandardError, 'Invalid OCR')
        end
      end

      context 'when an OCR string does not contain 3 characters' do
        let(:ocr) do
          [
            ['   ', ' _ ', ' _ ', ' _ ', ' ', ' _ ', ' _ ', ' _ ', ' _ '],
            ['|_|', '|_ ', '  |', '|_ ', '| |', '|_|', '| |', '| |', '| |'],
            ['  |', ' _|', '  |', ' _|', '|_|', '|_|', '|_|', '|_|', '|_|'],
            ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ']
          ]
        end

        it 'throws an exception' do
          expect{ subject }.to raise_error(StandardError, 'Invalid OCR')
        end
      end

      context 'when the OCR is valid' do
        let(:ocr) do
          [
            ['   ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ '],
            ['|_|', '|_ ', '  |', '|_ ', '| |', '|_|', '| |', '| |', '| |'],
            ['  |', ' _|', '  |', ' _|', '|_|', '|_|', '|_|', '|_|', '|_|'],
            ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ']
          ]
        end

        it 'does not throw an exception' do
          expect{ subject }.not_to raise_error
        end
      end
    end
  end

  describe '.valid?' do
    subject { policy_number.valid? }

    let(:ocr) do
      [
        ['   ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ '],
        ['|_|', '|_ ', '  |', '|_ ', '| |', '|_|', '| |', '| |', '| |'],
        ['  |', ' _|', '  |', ' _|', '|_|', '|_|', '|_|', '|_|', '|_|'],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ']
      ]
    end

    context 'when policy number has a valid checksum' do
      let(:policy_number) { PolicyNumber.new('123456789', ocr:) }

      it 'returns truthy' do
        expect(subject).to be_truthy
      end
    end

    context 'when policy number has an invalid checksum' do
      let(:policy_number) { PolicyNumber.new('023456789', ocr:) }

      it 'returns truthy' do
        expect(subject).to be_falsey
      end
    end
  end

  describe '.status' do
    subject { policy_number.status }

    let(:ocr) do
      [
        ['   ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ '],
        ['|_|', '|_ ', '  |', '|_ ', '| |', '|_|', '| |', '| |', '| |'],
        ['  |', ' _|', '  |', ' _|', '|_|', '|_|', '|_|', '|_|', '|_|'],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ']
      ]
    end

    context 'when the policy number contains ?' do
      let(:policy_number) { PolicyNumber.new('1234?6789', ocr:) }

      it 'returns ILL' do
        expect(subject).to be 'ILL'
      end
    end

    context 'when the policy number is not a valid policy number' do
      let(:policy_number) { PolicyNumber.new('023456789', ocr:) }

      it 'returns ERR' do
        expect(subject).to be 'ERR'
      end
    end

    context 'when the policy number is valid' do
      let(:policy_number) { PolicyNumber.new('123456789', ocr:) }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '.ocr' do
    subject { policy_number.ocr }

    let(:policy_number) do
      PolicyNumber.new(
        '457508000',
        ocr: [
          ['   ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ ', ' _ '],
          ['|_|', '|_ ', '  |', '|_ ', '| |', '|_|', '| |', '| |', '| |'],
          ['  |', ' _|', '  |', ' _|', '|_|', '|_|', '|_|', '|_|', '|_|'],
          ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ']
        ]
      )
    end

    context 'when called' do
      it 'returns a string' do
        expect(subject).to be_a String
      end

      it 'contains 4 EOLs' do
        expect(subject.count("\n")).to eql 4
      end

      it 'contains 4 lines with 27 characters each' do
        expect(subject.length).to eql 139
      end

      it 'only contains spaces, |, and _' do
        expect(subject.match(/[\s|_]{27}/)).not_to be_nil
      end
    end
  end
end
