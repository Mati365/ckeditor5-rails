# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Concerns::Checksum do
  let(:dummy_class) do
    Class.new do
      include CKEditor5::Rails::Concerns::Checksum

      public :calculate_object_checksum
    end
  end

  subject(:instance) { dummy_class.new }

  describe '#calculate_object_checksum' do
    it 'returns a 16-character string' do
      result = instance.calculate_object_checksum({ test: 'value' })
      expect(result).to eq(
        'f98be16ebfa861cb39a61faff9e52b33f5bcc16bb6ae72e728d226dc07093932'
      )
    end

    it 'returns consistent checksums for the same input' do
      input = { name: 'test', value: 123 }
      first_result = instance.calculate_object_checksum(input)
      second_result = instance.calculate_object_checksum(input)
      expect(first_result).to eq(second_result)
    end

    it 'returns different checksums for different inputs' do
      result1 = instance.calculate_object_checksum({ a: 1 })
      result2 = instance.calculate_object_checksum({ a: 2 })
      expect(result1).not_to eq(result2)
    end

    it 'handles arrays' do
      result = instance.calculate_object_checksum([1, 2, 3])
      expect(result).to eq(
        'a615eeaee21de5179de080de8c3052c8da901138406ba71c38c032845f7d54f4'
      )
    end

    it 'is order dependent for hashes' do
      result1 = instance.calculate_object_checksum({ a: 1, b: 2 })
      result2 = instance.calculate_object_checksum({ b: 2, a: 1 })
      expect(result1).not_to eq(result2)
    end
  end
end
