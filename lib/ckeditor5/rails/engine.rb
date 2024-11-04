# frozen_string_literal: true

require 'rails/engine'

require_relative 'presets/manager'
require_relative 'hooks/form'

module CKEditor5::Rails
  class Engine < ::Rails::Engine
    config.ckeditor5 = ActiveSupport::OrderedOptions.new
    config.ckeditor5.presets = Presets::Manager.new

    initializer 'helper' do
      ActiveSupport.on_load(:action_view) { include Helpers }
    end

    initializer 'ckeditor5.simple_form', if: -> { defined?(::SimpleForm) } do
      require_relative 'hooks/simple_form'
      ::SimpleForm::FormBuilder.map_type :ckeditor5, to: Hooks::SimpleForm::CKEditor5Input
    end

    initializer 'ckeditor5.form_builder' do
      require_relative 'hooks/form'
      ActionView::Helpers::FormBuilder.include(Hooks::Form::FormBuilderExtension)
    end

    class << self
      def base
        config.ckeditor5
      end

      def default_preset
        config.ckeditor5.presets.default
      end

      def configure(&block)
        proxy = ConfigurationProxy.new(config.ckeditor5)
        proxy.instance_eval(&block)
      end
    end

    class ConfigurationProxy
      delegate :presets, to: :@configuration

      delegate :version, :gpl, :premium, :cdn, :translations, :license_key,
               :type, :menubar, :toolbar, :plugins, :plugin, :inline_plugin,
               :language, :ckbox, :configure, to: :default_preset

      def initialize(configuration)
        @configuration = configuration
      end

      def default_preset
        presets.default
      end
    end
  end

  def self.configure(&block)
    Engine.configure(&block)
  end
end
