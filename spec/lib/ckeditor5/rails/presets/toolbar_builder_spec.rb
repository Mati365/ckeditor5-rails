# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Presets::ToolbarBuilder do
  let(:items) { %i[bold italic | link] }
  let(:builder) { described_class.new(items) }

  describe '#initialize' do
    it 'creates a builder with given items' do
      expect(builder.items).to eq(%i[bold italic | link])
    end
  end

  describe '#remove' do
    it 'removes specified items' do
      builder.remove(:italic, :|)
      expect(builder.items).to eq(%i[bold link])
    end

    it 'ignores non-existent items' do
      builder.remove(:nonexistent)
      expect(builder.items).to eq(%i[bold italic | link])
    end
  end

  describe '#prepend' do
    context 'without before option' do
      it 'adds items at the beginning' do
        builder.prepend(:underline, :strike)
        expect(builder.items).to eq(%i[underline strike bold italic | link])
      end
    end

    context 'with before option' do
      it 'adds items before specified item' do
        builder.prepend(:underline, before: :italic)
        expect(builder.items).to eq(%i[bold underline italic | link])
      end

      it 'raises error when target item not found' do
        expect do
          builder.prepend(:underline, before: :nonexistent)
        end.to raise_error(ArgumentError, "Item 'nonexistent' not found in array")
      end
    end
  end

  describe '#append' do
    context 'without after option' do
      it 'adds items at the end' do
        builder.append(:underline, :strike)
        expect(builder.items).to eq(%i[bold italic | link underline strike])
      end
    end

    context 'with after option' do
      it 'adds items after specified item' do
        builder.append(:underline, after: :italic)
        expect(builder.items).to eq(%i[bold italic underline | link])
      end

      it 'raises error when target item not found' do
        expect do
          builder.append(:underline, after: :nonexistent)
        end.to raise_error(ArgumentError, "Item 'nonexistent' not found in array")
      end
    end
  end
end
