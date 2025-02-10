# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Editor::PropsPatchPlugin do
  let(:plugin_name) { 'testPlugin' }
  let(:plugin_code) { 'console.log("test");' }

  describe '#initialize' do
    it 'creates plugin with version constraints' do
      plugin = described_class.new(plugin_name, plugin_code, min_version: '29.0.0', max_version: '30.0.0')

      expect(plugin.min_version.to_s).to eq('29.0.0')
      expect(plugin.max_version.to_s).to eq('30.0.0')
    end

    it 'creates plugin without version constraints' do
      plugin = described_class.new(plugin_name, plugin_code)

      expect(plugin.min_version).to be_nil
      expect(plugin.max_version).to be_nil
    end
  end

  describe '.applicable_for_version?' do
    it 'returns true when no version constraints' do
      expect(described_class.applicable_for_version?('29.0.0')).to be true
    end

    it 'returns true when version is within constraints' do
      result = described_class.applicable_for_version?(
        '29.1.0',
        min_version: '29.0.0',
        max_version: '30.0.0'
      )
      expect(result).to be true
    end

    it 'returns true when version is equal to min constraint' do
      result = described_class.applicable_for_version?(
        '29.0.0',
        min_version: '29.0.0'
      )
      expect(result).to be true
    end

    it 'returns true when version is equal to max constraint' do
      result = described_class.applicable_for_version?(
        '30.0.0',
        max_version: '30.0.0'
      )
      expect(result).to be true
    end

    it 'returns true when version is higher than min constraint (patch)' do
      result = described_class.applicable_for_version?(
        '29.0.1',
        min_version: '29.0.0'
      )
      expect(result).to be true
    end

    it 'returns true when version is higher than min constraint (minor)' do
      result = described_class.applicable_for_version?(
        '29.1.0',
        min_version: '29.0.0'
      )
      expect(result).to be true
    end

    it 'returns true when version is higher than min constraint (major)' do
      result = described_class.applicable_for_version?(
        '30.0.0',
        min_version: '29.0.0'
      )
      expect(result).to be true
    end

    it 'returns false when version is not equal to max constraint (patch)' do
      result = described_class.applicable_for_version?(
        '30.0.1',
        max_version: '30.0.0'
      )
      expect(result).to be false
    end

    it 'returns false when version is not equal to min constraint (minor)' do
      result = described_class.applicable_for_version?(
        '29.1.0',
        max_version: '29.0.0'
      )
      expect(result).to be false
    end

    it 'returns false when version is too low' do
      result = described_class.applicable_for_version?(
        '28.9.9',
        min_version: '29.0.0',
        max_version: '30.0.0'
      )
      expect(result).to be false
    end

    it 'returns false when version is too high' do
      result = described_class.applicable_for_version?(
        '30.0.1',
        min_version: '29.0.0',
        max_version: '30.0.0'
      )
      expect(result).to be false
    end
  end

  describe '#applicable_for_version?' do
    context 'with both version constraints' do
      let(:plugin) do
        described_class.new(plugin_name, plugin_code, min_version: '29.0.0', max_version: '30.0.0')
      end

      it 'returns true for version within constraints' do
        expect(plugin.applicable_for_version?('29.1.0')).to be true
      end

      it 'returns false for version outside constraints' do
        expect(plugin.applicable_for_version?('28.9.9')).to be false
      end
    end

    context 'with only min_version constraint' do
      let(:plugin) do
        described_class.new(plugin_name, plugin_code, min_version: '29.0.0')
      end

      it 'returns true for version above min_version' do
        expect(plugin.applicable_for_version?('30.0.0')).to be true
      end

      it 'returns false for version below min_version' do
        expect(plugin.applicable_for_version?('28.9.9')).to be false
      end
    end

    context 'with only max_version constraint' do
      let(:plugin) do
        described_class.new(plugin_name, plugin_code, max_version: '30.0.0')
      end

      it 'returns true for version below max_version' do
        expect(plugin.applicable_for_version?('29.0.0')).to be true
      end

      it 'returns false for version above max_version' do
        expect(plugin.applicable_for_version?('30.0.1')).to be false
      end
    end
  end
end
