# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Editor::PropsBasePlugin do
  let(:concrete_class) do
    Class.new(described_class) do
      def to_unsafe_h
        { type: :test, name: name }
      end
    end
  end

  let(:instance) { concrete_class.new(:TestPlugin) }

  describe '#initialize' do
    it 'sets the name attribute' do
      expect(instance.name).to eq(:TestPlugin)
    end
  end

  describe '#to_h' do
    it 'raises NotImplementedError' do
      expect { instance.to_h }.to raise_error(NotImplementedError)
    end
  end
end
