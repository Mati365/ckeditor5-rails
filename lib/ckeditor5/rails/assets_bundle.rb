# frozen_string_literal: true

module CKEditor5::Rails
  class AssetsBundle
    def initialize
      validate_implementation!
    end

    def empty?
      scripts.empty? && stylesheets.empty?
    end

    def preloads
      stylesheets + scripts.map(&:url)
    end

    def <<(other)
      raise TypeError, 'other must be an instance of AssetsBundle' unless other.is_a?(AssetsBundle)

      @scripts = scripts + other.scripts
      @stylesheets = stylesheets + other.stylesheets
    end

    class JSExportsMeta
      attr_reader :url, :import_name, :window_name

      def initialize(url, import_name: nil, window_name: nil)
        @url = url
        @import_name = import_name
        @window_name = window_name
      end

      def esm?
        import_name.present?
      end

      def umd?
        window_name.present?
      end
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
end
