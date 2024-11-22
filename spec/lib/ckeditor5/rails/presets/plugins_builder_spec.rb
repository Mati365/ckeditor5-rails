# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Presets::PluginsBuilder do
  let(:items) { [] }
  let(:builder) { described_class.new(items) }

  describe '.create_plugin' do
    context 'when name is a string' do
      it 'creates a new PropsPlugin' do
        plugin = described_class.create_plugin('Test')
        expect(plugin).to be_a(CKEditor5::Rails::Editor::PropsPlugin)
        expect(plugin.name).to eq('Test')
      end
    end

    context 'when name is already a plugin instance' do
      let(:existing_plugin) { CKEditor5::Rails::Editor::PropsPlugin.new('Test') }

      it 'returns the plugin instance unchanged' do
        plugin = described_class.create_plugin(existing_plugin)
        expect(plugin).to eq(existing_plugin)
      end
    end
  end

  describe '#remove' do
    before do
      items.push(
        CKEditor5::Rails::Editor::PropsPlugin.new('Plugin1'),
        CKEditor5::Rails::Editor::PropsPlugin.new('Plugin2'),
        CKEditor5::Rails::Editor::PropsPlugin.new('Plugin3')
      )
    end

    it 'removes specified plugins' do
      builder.remove('Plugin1', 'Plugin3')
      expect(items.map(&:name)).to eq(['Plugin2'])
    end
  end

  describe '#prepend' do
    let(:existing_plugin) { CKEditor5::Rails::Editor::PropsPlugin.new('ExistingPlugin') }

    before do
      items.push(existing_plugin)
    end

    context 'without before option' do
      it 'adds plugins at the beginning' do
        builder.prepend('NewPlugin1', 'NewPlugin2')
        expect(items.map(&:name)).to eq(%w[NewPlugin1 NewPlugin2 ExistingPlugin])
      end
    end

    context 'with before option' do
      it 'adds plugins before specified plugin' do
        builder.prepend('NewPlugin', before: 'ExistingPlugin')
        expect(items.map(&:name)).to eq(%w[NewPlugin ExistingPlugin])
      end

      it 'raises error when target plugin not found' do
        expect do
          builder.prepend('NewPlugin', before: 'NonExistent')
        end.to raise_error(ArgumentError, "Plugin 'NonExistent' not found")
      end
    end
  end

  describe '#append' do
    let(:existing_plugin) { CKEditor5::Rails::Editor::PropsPlugin.new('ExistingPlugin') }

    before do
      items.push(existing_plugin)
    end

    context 'without after option' do
      it 'adds plugins at the end' do
        builder.append('NewPlugin1', 'NewPlugin2')
        expect(items.map(&:name)).to eq(%w[ExistingPlugin NewPlugin1 NewPlugin2])
      end
    end

    context 'with after option' do
      it 'adds plugins after specified plugin' do
        builder.append('NewPlugin', after: 'ExistingPlugin')
        expect(items.map(&:name)).to eq(%w[ExistingPlugin NewPlugin])
      end

      it 'raises error when target plugin not found' do
        expect do
          builder.append('NewPlugin', after: 'NonExistent')
        end.to raise_error(ArgumentError, "Plugin 'NonExistent' not found")
      end
    end
  end
end
