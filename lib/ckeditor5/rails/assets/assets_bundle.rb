# frozen_string_literal: true

require 'active_support/core_ext/module'

module CKEditor5::Rails::Assets
  class AssetsBundle
    def initialize
      validate_implementation!
    end

    def empty?
      scripts.empty? && stylesheets.empty?
    end

    def translations_scripts
      scripts.select(&:translation?)
    end

    def preloads
      stylesheets + scripts.map(&:url)
    end

    def <<(other)
      raise TypeError, 'other must be an instance of AssetsBundle' unless other.is_a?(AssetsBundle)

      @scripts = scripts + other.scripts
      @stylesheets = stylesheets + other.stylesheets
    end

    private

    def validate_implementation!
      raise NotImplementedError, "#{self.class} must implement the #scripts method" unless respond_to?(
        :scripts, true
      )

      raise NotImplementedError, "#{self.class} must implement the #stylesheets method" unless respond_to?(
        :stylesheets, true
      )
    end
  end

  class JSExportsMeta
    attr_reader :url, :import_meta

    delegate :esm?, :window?, :import_name, :window_name, to: :import_meta

    def initialize(url, translation: false, **kwargs)
      @url = url
      @import_meta = JSImportMeta.new(**kwargs)
      @translation = translation
    end

    def translation?
      @translation
    end
  end

  class JSImportMeta
    attr_reader :import_as, :import_name, :window_name

    def initialize(import_as: nil, import_name: nil, window_name: nil)
      if import_name.nil? && window_name.nil?
        raise ArgumentError, 'import_name and window_name cannot be both nil'
      end

      if import_as && import_name.nil?
        raise ArgumentError, 'import_name must be defined if import_as is defined'
      end

      @import_as = import_as
      @import_name = import_name
      @window_name = window_name
    end

    def esm?
      import_name.present?
    end

    def window?
      window_name.present?
    end

    def to_h
      {
        import_as: import_as,
        import_name: import_name,
        window_name: window_name
      }.compact
    end
  end
end
