# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::VersionDetector do
  let(:current_version) { '35.1.0' }

  let(:npm_response) do
    {
      'versions' => {
        '34.0.0' => {},
        '34.1.0' => {},
        '35.0.0' => {},
        '35.1.0' => {},
        '35.2.0' => {},
        '36.0.0' => {},
        '35.2.1-dev' => {},
        '36.0.0-nightly' => {}
      }
    }.to_json
  end

  let(:success_response) do
    double('Net::HTTPSuccess',
           body: npm_response,
           is_a?: true)
  end

  before do
    described_class.instance.clear_cache!

    allow(Net::HTTP).to receive(:new).and_return(
      double('Net::HTTP').tap do |http|
        allow(http).to receive(:use_ssl=)
        allow(http).to receive(:open_timeout=)
        allow(http).to receive(:read_timeout=)
        allow(http).to receive(:get).and_return(success_response)
      end
    )
  end

  describe '.latest_safe_version' do
    before do
      described_class.instance.clear_cache!
      setup_http_mock(success_response)
    end

    it 'returns the latest safe version' do
      expect(described_class.latest_safe_version(current_version)).to eq('35.2.0')
    end

    it 'caches the result' do
      first_call = described_class.latest_safe_version(current_version)

      # Simulate different NPM response
      allow(success_response).to receive(:body).and_return(
        { 'versions' => { '35.3.0' => {} } }.to_json
      )

      second_call = described_class.latest_safe_version(current_version)

      expect(first_call).to eq(second_call)
    end
  end

  describe 'error handling' do
    before do
      described_class.instance.clear_cache!
    end

    context 'when HTTP request fails' do
      before do
        allow(Net::HTTP).to receive(:new).and_raise(StandardError.new('Connection failed'))
        allow_any_instance_of(Kernel).to receive(:warn)
      end

      it 'returns nil and logs warning' do
        expect_any_instance_of(Kernel).to receive(:warn).with('Error fetching versions: Connection failed')
        expect(described_class.latest_safe_version(current_version)).to be_nil
      end
    end

    context 'when response is not successful' do
      let(:error_response) do
        double('Net::HTTPNotFound',
               is_a?: false)
      end

      before do
        setup_http_mock(error_response)
        allow_any_instance_of(Kernel).to receive(:warn)
      end

      it 'returns nil and logs warning' do
        expect_any_instance_of(Kernel).to receive(:warn).with('Failed to fetch CKEditor versions')
        expect(described_class.latest_safe_version(current_version)).to be_nil
      end
    end
  end

  describe 'version filtering' do
    before do
      described_class.instance.clear_cache!
      setup_http_mock(success_response)
    end

    it 'ignores nightly and dev versions' do
      latest = described_class.latest_safe_version(current_version)
      expect(latest).not_to include('nightly')
      expect(latest).not_to include('dev')
    end

    it 'only returns versions safe to update to' do
      expect(described_class.latest_safe_version('35.0.0')).to eq('35.2.0')
      expect(described_class.latest_safe_version('34.0.0')).to eq('34.1.0')
    end
  end

  private

  def setup_http_mock(response)
    allow(Net::HTTP).to receive(:new).and_return(
      double('Net::HTTP').tap do |http|
        allow(http).to receive(:use_ssl=)
        allow(http).to receive(:open_timeout=)
        allow(http).to receive(:read_timeout=)
        allow(http).to receive(:get).and_return(response)
      end
    )
  end
end
