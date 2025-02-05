# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Presets::SpecialCharactersBuilder do
  subject(:builder) { described_class.new }

  describe '#group' do
    it 'creates a group with items array' do
      group = builder.group('Arrows', items: [
                              { title: 'right', character: '→' },
                              { title: 'left', character: '←' }
                            ])

      expect(group.to_h).to eq({
                                 name: 'Arrows',
                                 items: [
                                   { title: 'right', character: '→' },
                                   { title: 'left', character: '←' }
                                 ],
                                 options: {}
                               })
    end

    it 'creates a group with block syntax' do
      group = builder.group('Emoji', label: 'Emoticons') do
        item 'smiley', '😊'
        item 'heart', '❤️'
      end

      expect(group.to_h).to eq({
                                 name: 'Emoji',
                                 items: [
                                   { title: 'smiley', character: '😊' },
                                   { title: 'heart', 'character': '❤️' }
                                 ],
                                 options: { label: 'Emoticons' }
                               })
    end

    it 'creates a group with mixed configuration' do
      group = builder.group('Mixed',
                            items: [{ title: 'star', character: '⭐' }],
                            label: 'Mixed Characters') do
        item 'heart', '❤️'
      end

      expect(group.to_h).to eq({
                                 name: 'Mixed',
                                 items: [
                                   { title: 'star', character: '⭐' },
                                   { title: 'heart', 'character': '❤️' }
                                 ],
                                 options: { label: 'Mixed Characters' }
                               })
    end
  end

  describe '#packs' do
    it 'registers special characters plugins' do
      builder.packs(:Text, :Mathematical, :Currency)

      expect(builder.packs_plugins).to eq(%w[
                                            SpecialCharactersText
                                            SpecialCharactersMathematical
                                            SpecialCharactersCurrency
                                          ])
    end
  end

  describe '#order' do
    it 'sets the display order of character groups' do
      builder.order(:Text, :Mathematical, 'Currency', :Emoji)

      expect(builder.to_h[:order]).to eq(%w[Text Mathematical Currency Emoji])
    end
  end

  describe '#to_h' do
    it 'returns complete configuration' do
      builder.group('Emoji', label: 'Emoticons') do
        item 'smiley', '😊'
      end

      builder.packs(:Text, :Mathematical)
      builder.order(:Text, :Mathematical, :Emoji)

      expect(builder.to_h).to eq({
                                   groups: [{
                                     name: 'Emoji',
                                     items: [{ title: 'smiley', character: '😊' }],
                                     options: { label: 'Emoticons' }
                                   }],
                                   order: %w[Text Mathematical Emoji],
                                   packs: %w[SpecialCharactersText SpecialCharactersMathematical]
                                 })
    end
  end

  describe CKEditor5::Rails::Presets::SpecialCharactersBuilder::Group do
    subject(:group) { described_class.new('Test', label: 'Test Group') }

    describe '#item' do
      it 'adds a single character' do
        group.item('test', '*')
        expect(group.to_h[:items]).to eq([{ title: 'test', character: '*' }])
      end
    end

    describe '#add_items' do
      it 'adds multiple characters' do
        group.add_items([
                          { title: 'star', character: '⭐' },
                          { title: 'heart', 'character': '❤️' }
                        ])

        expect(group.to_h[:items]).to eq([
                                           { title: 'star', character: '⭐' },
                                           { title: 'heart', 'character': '❤️' }
                                         ])
      end

      it 'filters out invalid keys' do
        group.add_items([
                          { title: 'star', character: '⭐', invalid: 'key' }
                        ])

        expect(group.to_h[:items]).to eq([
                                           { title: 'star', character: '⭐' }
                                         ])
      end
    end

    describe '#to_h' do
      it 'includes group name, items and options' do
        group.item('test', '*')

        expect(group.to_h).to eq({
                                   name: 'Test',
                                   items: [{ title: 'test', character: '*' }],
                                   options: { label: 'Test Group' }
                                 })
      end

      it 'omits empty options' do
        group = described_class.new('Test')
        group.item('test', '*')

        expect(group.to_h).to eq({
                                   name: 'Test',
                                   items: [{ title: 'test', character: '*' }],
                                   options: {}
                                 })
      end
    end
  end
end
