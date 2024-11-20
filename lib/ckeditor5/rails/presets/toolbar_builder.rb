# frozen_string_literal: true

module CKEditor5::Rails::Presets
  class ToolbarBuilder
    attr_reader :items

    def initialize(items)
      @items = items
    end

    def remove(*removed_items)
      removed_items.each { |item| items.delete(item) }
    end

    def prepend(*prepended_items, before: nil)
      if before
        index = items.index(before)
        raise ArgumentError, "Item '#{before}' not found in array" unless index

        items.insert(index, *prepended_items)
      else
        items.insert(0, *prepended_items)
      end
    end

    def append(*appended_items, after: nil)
      if after
        index = items.index(after)
        raise ArgumentError, "Item '#{after}' not found in array" unless index

        items.insert(index + 1, *appended_items)
      else
        items.push(*appended_items)
      end
    end
  end
end
