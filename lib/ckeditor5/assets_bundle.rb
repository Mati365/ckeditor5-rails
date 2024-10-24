# frozen_string_literal: true

class Ckeditor5::AssetsBundle
  def js_exports = raise(NotImplementedError)
  def scripts = raise(NotImplementedError)
  def stylesheets = raise(NotImplementedError)

  def empty?
    scripts.empty? && stylesheets.empty?
  end

  def preload_links
    (scripts + stylesheets).uniq
  end

  def merge!(other)
    unless empty?
      @scripts = (scripts + other.scripts).uniq
      @css = (stylesheets + other.stylesheets).uniq
    end

    self
  end

  def merge(other)
    dup.merge!(other)
  end

  class JSExportsMeta
    attr_reader :import_name, :window_name

    def initialize(import_name:, window_name:)
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
end
