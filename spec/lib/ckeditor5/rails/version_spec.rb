# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails do
  describe 'VERSION' do
    it 'is defined as a string' do
      expect(described_class::VERSION).to be_a(String)
    end

    it 'follows semantic versioning format' do
      expect(described_class::VERSION).to match(/^\d+\.\d+\.\d+$/)
    end
  end

  describe 'DEFAULT_CKEDITOR_VERSION' do
    it 'is defined as a string' do
      expect(described_class::DEFAULT_CKEDITOR_VERSION).to be_a(String)
    end

    it 'follows semantic versioning format' do
      expect(described_class::DEFAULT_CKEDITOR_VERSION).to match(/^\d+\.\d+\.\d+$/)
    end
  end
end
