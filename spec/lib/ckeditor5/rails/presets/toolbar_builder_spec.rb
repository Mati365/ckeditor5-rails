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

  describe '#break_line' do
    it 'returns line break symbol' do
      expect(builder.break_line).to eq(:-)
    end
  end

  describe '#separator' do
    it 'returns separator symbol' do
      expect(builder.separator).to eq(:|)
    end
  end

  describe '#group' do
    it 'creates and adds a new group' do
      builder.group(:text, label: 'Text') do
        append(:bold, :italic)
      end

      group = builder.items.last
      expect(group).to be_a(CKEditor5::Rails::Presets::ToolbarGroupItem)
      expect(group.name).to eq(:text)
      expect(group.items).to eq(%i[bold italic])
      expect(group.label).to eq('Text')
    end

    it 'creates group without configuration block' do
      group = builder.group(:text, label: 'Text')

      expect(group).to be_a(CKEditor5::Rails::Presets::ToolbarGroupItem)
      expect(group.items).to be_empty
    end
  end

  describe '#find_group' do
    it 'returns group by name' do
      builder.group(:text, label: 'Text')
      builder.group(:formatting, label: 'Format')

      group = builder.find_group(:formatting)
      expect(group).to be_a(CKEditor5::Rails::Presets::ToolbarGroupItem)
      expect(group.name).to eq(:formatting)
    end

    it 'returns nil when group not found' do
      expect(builder.find_group(:nonexistent)).to be_nil
    end
  end

  describe '#remove_group' do
    it 'removes group by name' do
      builder.group(:text, label: 'Text')
      builder.group(:formatting, label: 'Format')

      builder.remove_group(:text)
      expect(builder.find_group(:text)).to be_nil
      expect(builder.find_group(:formatting)).to be_present
    end

    it 'ignores non-existent groups' do
      builder.group(:text, label: 'Text')

      expect { builder.remove_group(:nonexistent) }.not_to(change { builder.items.count })
    end
  end

  describe 'interacting with groups' do
    let(:text_group) do
      builder.group(:text, label: 'Text') do
        append(:bold, :italic)
      end
    end

    before do
      text_group
    end

    it 'prepends items before group' do
      builder.prepend(:undo, :redo, before: :text)
      expect(builder.items.map { |i| i.is_a?(CKEditor5::Rails::Presets::ToolbarGroupItem) ? i.name : i })
        .to eq(%i[bold italic | link undo redo text])
    end

    it 'appends items after group' do
      builder.append(:undo, :redo, after: :text)
      expect(builder.items.map { |i| i.is_a?(CKEditor5::Rails::Presets::ToolbarGroupItem) ? i.name : i })
        .to eq(%i[bold italic | link text undo redo])
    end

    it 'removes group using remove method' do
      builder.remove(:text)
      expect(builder.items).to eq(%i[bold italic | link])
    end
  end
end

RSpec.describe CKEditor5::Rails::Presets::ToolbarGroupItem do
  let(:items) { %i[bold italic] }
  let(:group) { described_class.new(:formatting, items, label: 'Format', icon: 'format') }

  describe '#initialize' do
    it 'creates a group with given parameters' do
      expect(group.name).to eq(:formatting)
      expect(group.items).to eq(items)
      expect(group.label).to eq('Format')
      expect(group.icon).to eq('format')
    end
  end

  it 'inherits toolbar manipulation methods' do
    group.append(:underline)
    expect(group.items).to eq(%i[bold italic underline])

    group.prepend(:heading)
    expect(group.items).to eq(%i[heading bold italic underline])

    group.remove(:italic)
    expect(group.items).to eq(%i[heading bold underline])
  end
end
