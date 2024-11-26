# frozen_string_literal: true

require 'spec_helper'
require 'action_view'

RSpec.describe CKEditor5::Rails::Editor::Helpers::Editor do
  let(:test_class) do
    Class.new do
      include ActionView::Helpers::TagHelper
      include CKEditor5::Rails::Editor::Helpers::Editor
    end
  end

  let(:helper) { test_class.new }
  let(:preset) { instance_double(CKEditor5::Rails::Presets::PresetBuilder) }
  let(:context) { { preset: :default, cdn: :jsdelivr } }

  before do
    helper.instance_variable_set(:@__ckeditor_context, context)
    allow(preset).to receive(:type).and_return(:classic)
    allow(preset).to receive(:config).and_return({})
    allow(preset).to receive(:automatic_upgrades?).and_return(false)
  end

  describe '#ckeditor5_editor' do
    before do
      allow(helper).to receive(:find_preset).and_return(preset)
    end

    it 'raises error when context is not defined' do
      helper.remove_instance_variable(:@__ckeditor_context)
      expect { helper.ckeditor5_editor }.to raise_error(
        described_class::EditorContextError,
        /CKEditor installation context is not defined/
      )
    end

    it 'raises error when preset is not found' do
      allow(helper).to receive(:find_preset).and_raise(described_class::PresetNotFoundError)
      expect do
        helper.ckeditor5_editor(preset: :unknown)
      end.to raise_error(described_class::PresetNotFoundError)
    end

    it 'merges extra configuration with preset config' do
      extra_config = { toolbar: { items: ['bold'] } }
      expect(helper).to receive(:build_editor_config)
        .with(preset, nil, extra_config, nil)
        .and_return(extra_config)

      helper.ckeditor5_editor(extra_config: extra_config)
    end

    it 'sets initial data in config when provided' do
      expect(helper).to receive(:build_editor_config)
        .with(preset, nil, {}, 'initial content')
        .and_call_original

      helper.ckeditor5_editor(initial_data: 'initial content')
    end

    it 'cannot have both initial_data and block content' do
      expect do
        helper.ckeditor5_editor(initial_data: 'content') { 'block content' }
      end.to raise_error(ArgumentError, /Cannot pass initial data and block/)
    end

    context 'when language is present' do
      it 'passes language to editor props' do
        result = helper.ckeditor5_editor(language: 'pl')

        expect(result).to include('config=')
        config_attr = result.match(/config="([^"]+)"/)[1]
        decoded_config = CGI.unescape_html(config_attr)
        parsed_config = JSON.parse(decoded_config)

        expect(parsed_config['language']).to eq({ 'ui' => 'pl' })
      end
    end

    context 'when automatic upgrades are enabled' do
      before do
        allow(preset).to receive(:automatic_upgrades?).and_return(true)
      end

      it 'updates version when detector finds newer safe version' do
        extra_config = { version: '35.1.0' }
        allow(CKEditor5::Rails::VersionDetector).to receive(:latest_safe_version)
          .with('35.1.0')
          .and_return('35.3.0')

        result = helper.ckeditor5_editor(extra_config: extra_config)
        expect(result).to include('35.3.0')
      end

      it 'keeps original version when no safe upgrade is available' do
        extra_config = { version: '35.1.0' }
        allow(CKEditor5::Rails::VersionDetector).to receive(:latest_safe_version)
          .with('35.1.0')
          .and_return(nil)

        result = helper.ckeditor5_editor(extra_config: extra_config)
        expect(result).to include('35.1.0')
      end

      it 'skips version detection when version is not specified' do
        expect(CKEditor5::Rails::VersionDetector).not_to receive(:latest_safe_version)
        helper.ckeditor5_editor
      end
    end

    context 'when automatic upgrades are disabled' do
      before do
        allow(preset).to receive(:automatic_upgrades?).and_return(false)
      end

      it 'does not modify version even when newer version is available' do
        extra_config = { version: '35.1.0' }
        expect(CKEditor5::Rails::VersionDetector).not_to receive(:latest_safe_version)

        result = helper.ckeditor5_editor(extra_config: extra_config)
        expect(result).to include('35.1.0')
      end
    end

    context 'when using preset lookup' do
      before do
        RSpec::Mocks.space.proxy_for(helper).remove_stub(:find_preset)
      end

      it 'uses default preset when none specified' do
        expect(CKEditor5::Rails::Engine).to receive(:find_preset)
          .with(:default)
          .and_return(preset)

        helper.ckeditor5_editor
      end

      it 'uses preset from context when available' do
        helper.instance_variable_set(:@__ckeditor_context, { preset: :custom })
        expect(CKEditor5::Rails::Engine).to receive(:find_preset)
          .with(:custom)
          .and_return(preset)

        helper.ckeditor5_editor
      end

      it 'prefers explicitly passed preset over context preset' do
        helper.instance_variable_set(:@__ckeditor_context, { preset: :from_context })
        expect(CKEditor5::Rails::Engine).to receive(:find_preset)
          .with(:explicit)
          .and_return(preset)

        helper.ckeditor5_editor(preset: :explicit)
      end

      it 'raises error when preset cannot be found' do
        allow(CKEditor5::Rails::Engine).to receive(:find_preset)
          .with(:unknown)
          .and_return(nil)

        expect { helper.ckeditor5_editor(preset: :unknown) }.to raise_error(
          described_class::PresetNotFoundError,
          'Preset unknown is not defined.'
        )
      end
    end
  end

  describe '#ckeditor5_editable' do
    it 'creates editable component with name' do
      expect(helper.ckeditor5_editable('content')).to have_tag(
        'ckeditor-editable-component',
        with: { name: 'content' }
      )
    end
  end

  describe '#ckeditor5_ui_part' do
    it 'creates ui part component with name' do
      expect(helper.ckeditor5_ui_part('toolbar')).to have_tag(
        'ckeditor-ui-part-component',
        with: { name: 'toolbar' }
      )
    end
  end

  describe '#ckeditor5_toolbar' do
    it 'creates toolbar ui part' do
      expect(helper.ckeditor5_toolbar).to have_tag(
        'ckeditor-ui-part-component',
        with: { name: 'toolbar' }
      )
    end
  end

  describe '#ckeditor5_menubar' do
    it 'creates menubar ui part' do
      expect(helper.ckeditor5_menubar).to have_tag(
        'ckeditor-ui-part-component',
        with: { name: 'menuBarView' }
      )
    end
  end
end
