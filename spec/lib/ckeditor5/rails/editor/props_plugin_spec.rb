# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Editor::PropsPlugin do
  describe '#to_h' do
    it 'generates hash for standard plugin' do
      plugin = described_class.new(:Bold)
      expect(plugin.to_h).to include(
        type: :external,
        import_name: 'ckeditor5',
        import_as: :Bold
      )
    end

    it 'generates hash for premium plugin' do
      plugin = described_class.new(:Bold, premium: true)
      expect(plugin.to_h).to include(
        type: :external,
        import_name: 'ckeditor5-premium-features',
        import_as: :Bold
      )
    end

    it 'handles custom import metadata' do
      plugin = described_class.new(:Custom,
                                   import_name: 'custom-module',
                                   window_name: 'CustomPlugin')
      expect(plugin.to_h).to include(
        type: :external,
        import_name: 'custom-module',
        window_name: 'CustomPlugin'
      )
    end
  end
end
