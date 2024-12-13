# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Editor::EditableHeightNormalizer do
  subject(:normalizer) { described_class.new(editor_type) }

  describe '#normalize' do
    shared_examples 'height normalization' do
      it 'returns nil when value is nil' do
        expect(normalizer.normalize(nil)).to be_nil
      end

      it 'converts integer to pixel string' do
        expect(normalizer.normalize(500)).to eq('500px')
      end

      it 'accepts valid pixel string' do
        expect(normalizer.normalize('300px')).to eq('300px')
      end

      it 'raises error for invalid string format' do
        expect { normalizer.normalize('500') }.to raise_error(
          CKEditor5::Rails::Editor::InvalidEditableHeightError,
          /editable_height must be an integer representing pixels or string ending with 'px'/
        )
      end

      it 'raises error for invalid value type' do
        expect { normalizer.normalize([]) }.to raise_error(
          CKEditor5::Rails::Editor::InvalidEditableHeightError,
          /editable_height must be an integer representing pixels or string ending with 'px'/
        )
      end
    end

    context 'when editor type is classic' do
      let(:editor_type) { :classic }
      include_examples 'height normalization'
    end

    context 'when editor type is balloon' do
      let(:editor_type) { :balloon }
      include_examples 'height normalization'
    end

    context 'when editor type is not supported' do
      let(:editor_type) { :inline }

      it 'raises error' do
        expect { normalizer.normalize(500) }.to raise_error(
          CKEditor5::Rails::Editor::InvalidEditableHeightError,
          'editable_height can be used only with ClassicEditor or BalloonEditor'
        )
      end
    end
  end
end
