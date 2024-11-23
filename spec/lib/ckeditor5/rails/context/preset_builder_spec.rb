# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Context::PresetBuilder do
  subject(:builder) { described_class.new }

  describe '#initialize' do
    it 'creates empty config with plugins array' do
      expect(builder.config).to eq({ plugins: [] })
    end

    it 'accepts configuration block' do
      builder = described_class.new do
        configure :language, 'en'
      end

      expect(builder.config[:language]).to eq('en')
    end
  end

  describe '#initialize_copy' do
    let(:original) do
      described_class.new do
        configure :language, 'en'
        plugin 'Test'
      end
    end

    it 'creates deep copy of config' do
      copy = original.dup

      expect(copy.config).not_to be(original.config)
      expect(copy.config[:plugins]).not_to be(original.config[:plugins])
      expect(copy.config[:plugins].first).not_to be(original.config[:plugins].first)
    end
  end

  describe '#configure' do
    it 'sets config value' do
      builder.configure(:toolbar, { items: ['bold'] })
      expect(builder.config[:toolbar]).to eq({ items: ['bold'] })
    end
  end

  describe '#plugin' do
    it 'adds normalized plugin to config' do
      plugin = builder.plugin('Test')

      expect(builder.config[:plugins]).to include(plugin)
      expect(plugin).to be_a(CKEditor5::Rails::Editor::PropsPlugin)
    end

    it 'accepts plugin options' do
      plugin = builder.plugin('Test', premium: true)

      expect(plugin.js_import_meta[:import_name]).to eq('ckeditor5-premium-features')
    end
  end

  describe '#plugins' do
    it 'adds multiple plugins at once' do
      builder.plugins('Test1', 'Test2')

      expect(builder.config[:plugins].map(&:name)).to eq(%w[Test1 Test2])
    end

    it 'accepts block for complex configuration' do
      builder.plugins do
        append 'Test1'
        append 'Test2', premium: true
      end

      expect(builder.config[:plugins].map(&:name)).to eq(%w[Test1 Test2])
    end

    it 'accepts both arguments and block' do
      builder.plugins('Test1') do
        append 'Test2'
      end

      expect(builder.config[:plugins].map(&:name)).to eq(%w[Test1 Test2])
    end
  end
end