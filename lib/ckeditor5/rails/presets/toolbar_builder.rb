# frozen_string_literal: true

module CKEditor5::Rails::Presets
  # Builder class for configuring CKEditor5 toolbar items.
  #
  # @example Basic toolbar configuration
  #   toolbar = ToolbarBuilder.new([:bold, :italic])
  #   toolbar.append(:link)
  #   toolbar.prepend(:heading)
  class ToolbarBuilder
    attr_reader :items

    # Initialize a new toolbar builder with given items.
    #
    # @param items [Array<Symbol>] Initial toolbar items
    # @example Create new toolbar
    #   ToolbarBuilder.new([:bold, :italic, :|, :link])
    def initialize(items)
      @items = items
    end

    # Returns toolbar line break symbol
    #
    # @return [Symbol] Line break symbol (-)
    # @example Add line break to toolbar
    #   toolbar do
    #     append :bold, break_line, :italic
    #   end
    def break_line
      :-
    end

    # Returns toolbar separator symbol
    #
    # @return [Symbol] Separator symbol (|)
    # @example Add separator to toolbar
    #   toolbar do
    #     append :bold, separator, :italic
    #   end
    def separator
      :|
    end

    # Remove items from the editor toolbar.
    #
    # @param removed_items [Array<Symbol>] Toolbar items to be removed
    # @example Remove items from toolbar
    #   toolbar do
    #     remove :underline, :heading
    #   end
    def remove(*removed_items)
      items.delete_if do |existing_item|
        removed_items.any? { |item_to_remove| item_matches?(existing_item, item_to_remove) }
      end
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
        index = find_item_index(before)
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
        index = find_item_index(after)
        raise ArgumentError, "Item '#{after}' not found in array" unless index

        items.insert(index + 1, *appended_items)
      else
        items.push(*appended_items)
      end
    end

    # Find group by name in toolbar items
    #
    # @param name [Symbol] Group name to find
    # @return [ToolbarGroupItem, nil] Found group or nil
    def find_group(name)
      items.find { |item| item.is_a?(ToolbarGroupItem) && item.name == name }
    end

    # Remove group by name from toolbar items
    #
    # @param name [Symbol] Group name to remove
    def remove_group(name)
      items.delete_if { |item| item.is_a?(ToolbarGroupItem) && item.name == name }
    end

    # Create and add new group to toolbar
    #
    # @param name [Symbol] Group name
    # @param options [Hash] Group options (label:, icons:)
    # @param block [Proc] Configuration block
    # @return [ToolbarGroupItem] Created group
    def group(name, **options, &block)
      group = ToolbarGroupItem.new(name, [], **options)
      group.instance_eval(&block) if block_given?
      items << group
      group
    end

    private

    # Find index of an item or group by name
    #
    # @param item [Symbol] Item or group name to find
    # @return [Integer, nil] Index of the found item or nil
    def find_item_index(item)
      items.find_index { |existing_item| item_matches?(existing_item, item) }
    end

    # Checks if the existing item matches the given item or group name
    #
    # @param existing_item [Symbol, ToolbarGroupItem] Item to check
    # @param item [Symbol] Item or group name to match against
    # @return [Boolean] true if items match, false otherwise
    # @example Check if items match
    #   item_matches?(:bold, :bold)           # => true
    #   item_matches?(group(:text), :text)    # => true
    def item_matches?(existing_item, item)
      if existing_item.is_a?(ToolbarGroupItem)
        existing_item.name == item
      else
        existing_item == item
      end
    end
  end

  # Builder class for configuring CKEditor5 toolbar groups.
  # Allows creating named groups of toolbar items with optional labels and icons.
  #
  # @example Creating a text formatting group
  #   group = ToolbarGroupItem.new(:text_formatting, [:bold, :italic], label: 'Text')
  #   group.append(:underline)
  class ToolbarGroupItem < ToolbarBuilder
    attr_reader :name, :label, :icon

    # Initialize a new toolbar group item.
    #
    # @param name [Symbol] Name of the toolbar group
    # @param items [Array<Symbol>, ToolbarBuilder] Items to be included in the group
    # @param label [String, nil] Optional label for the group
    # @param icon [String, nil] Optional icon for the group
    # @example Create a new toolbar group
    #   ToolbarGroupItem.new(:text, [:bold, :italic], label: 'Text formatting')
    def initialize(name, items = [], label: nil, icon: nil)
      super(items)
      @name = name
      @label = label
      @icon = icon
    end
  end
end
