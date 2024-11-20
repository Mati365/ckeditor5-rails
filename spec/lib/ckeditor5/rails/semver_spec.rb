# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Semver do
  describe '#initialize' do
    context 'with valid version string' do
      it 'accepts version in x.y.z format' do
        expect { described_class.new('1.2.3') }.not_to raise_error
      end
    end

    context 'with invalid version' do
      it 'raises error for numeric input' do
        expect { described_class.new(123) }
          .to raise_error(ArgumentError, 'invalid version format')
      end

      it 'raises error for invalid string format' do
        invalid_versions = ['1', '1.2', '1.2.3.4', 'x.y.z', '1.2.x', '1.a.3']

        invalid_versions.each do |version|
          expect { described_class.new(version) }
            .to raise_error(ArgumentError, 'invalid version format')
        end
      end
    end
  end

  describe '#to_s' do
    it 'returns the version string' do
      version = '1.2.3'
      semver = described_class.new(version)
      expect(semver.to_s).to eq(version)
    end
  end

  describe '#version' do
    it 'returns the version string' do
      version = '1.2.3'
      semver = described_class.new(version)
      expect(semver.version).to eq(version)
    end
  end
end
