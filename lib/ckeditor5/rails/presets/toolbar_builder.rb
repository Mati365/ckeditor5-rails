# frozen_string_literal: true

module CKEditor5::Rails::Presets
  class ToolbarBuilder
    attr_reader :items

    def initialize(items)
      @items = items
    end

    # Remove items from the editor toolbar.
    #
    # @param removed_items [Array<Symbol>] Toolbar items to be removed
    # @example Remove items from toolbar
    #   toolbar do
    #     remove :underline, :heading
    #   end
    def remove(*removed_items)
      removed_items.each { |item| items.delete(item) }
    end

    # Prepend items to the editor toolbar.
    #
    # @param prepended_items [Array<Symbol>] Toolbar items to be prepended
    # @param before [Symbol, nil] Optional item before which to insert new items
    # @example Prepend items to toolbar
    #   toolbar do
    #     prepend :selectAll, :|, :selectAll, :selectAll
    #   end
    # @example Insert items before specific item
    #   toolbar do
    #     prepend :selectAll, before: :bold
    #   end
    # @raise [ArgumentError] When the specified 'before' item is not found
    def prepend(*prepended_items, before: nil)
      if before
        index = items.index(before)
        raise ArgumentError, "Item '#{before}' not found in array" unless index

        items.insert(index, *prepended_items)
      else
        items.insert(0, *prepended_items)
      end
    end

    # Append items to the editor toolbar.
    #
    # @param appended_items [Array<Symbol>] Toolbar items to be appended
    # @param after [Symbol, nil] Optional item after which to insert new items
    # @example Append items to toolbar
    #   toolbar do
    #     append :selectAll, :|, :selectAll, :selectAll
    #   end
    # @example Insert items after specific item
    #   toolbar do
    #     append :selectAll, after: :bold
    #   end
    # @raise [ArgumentError] When the specified 'after' item is not found
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
