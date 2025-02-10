# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Semver do
  describe '#initialize' do
    context 'with valid version string' do
      it 'accepts version in x.y.z format' do
        expect { described_class.new('1.2.3') }.not_to raise_error
      end

      it 'accepts Semver object' do
        original = described_class.new('1.2.3')
        copied = described_class.new(original)

        expect(copied.major).to eq(1)
        expect(copied.minor).to eq(2)
        expect(copied.patch).to eq(3)
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

  describe '#<=>' do
    let(:version1) { described_class.new('1.2.3') }

    it 'compares versions correctly' do
      expect(version1).to be < described_class.new('1.2.4')
      expect(version1).to be < described_class.new('1.3.0')
      expect(version1).to be < described_class.new('2.0.0')
      expect(version1).to be > described_class.new('1.2.2')
      expect(version1).to be > described_class.new('1.1.9')
      expect(version1).to be > described_class.new('0.9.9')
      expect(version1).to eq described_class.new('1.2.3')
    end

    it 'returns nil when comparing with non-Semver object' do
      expect(version1 <=> 'not a version').to be_nil
    end
  end

  describe '#safe_update?' do
    let(:base_version) { described_class.new('1.2.3') }

    context 'when major version changes' do
      it 'returns false for major version increase' do
        expect(base_version.safe_update?('2.0.0')).to be false
      end

      it 'returns false for major version decrease' do
        expect(base_version.safe_update?('0.2.3')).to be false
      end
    end

    context 'when minor version changes' do
      it 'returns true for minor version increase' do
        expect(base_version.safe_update?('1.3.0')).to be true
      end

      it 'returns false for minor version decrease' do
        expect(base_version.safe_update?('1.1.9')).to be false
      end
    end

    context 'when patch version changes' do
      it 'returns true for patch version increase' do
        expect(base_version.safe_update?('1.2.4')).to be true
      end

      it 'returns false for patch version decrease' do
        expect(base_version.safe_update?('1.2.2')).to be false
      end
    end

    context 'when version is the same' do
      it 'returns false for identical version' do
        expect(base_version.safe_update?('1.2.3')).to be false
      end
    end
  end
end
