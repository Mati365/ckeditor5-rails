# frozen_string_literal: true

module CKEditor5::Rails::Presets
  # Builder class for configuring special characters in CKEditor5
  #
  # @example Basic configuration
  #   special_characters do
  #     group 'Emoji', label: 'Emoticons' do
  #       item 'smiley', '😊'
  #     end
  #
  #     order :Text, :Mathematical, :Emoji
  #   end
  class SpecialCharactersBuilder
    attr_reader :packs_plugins

    # Builder class for configuring special characters groups
    #
    # @example Basic group configuration
    #   group = Group.new('Emoji', label: 'Emoticons')
    #   group.item('smiley', '😊')
    class Group
      attr_reader :name, :label, :items

      # Initialize a new special characters group
      #
      # @param name [String] Name of the group
      # @param label [String, nil] Optional display label for the group
      def initialize(name, label: nil)
        @name = name
        @label = label
        @items = []
      end

      # Add a single character to the group
      #
      # @param title [String] Character title/description
      # @param character [String] The special character
      # @example Add smiley face
      #   item 'smiley face', '😊'
      def item(title, character)
        @items << { title: title, character: character }
      end

      # Add multiple characters to the group at once
      #
      # @param collection [Array<Hash>] Array of character definitions
      # @example Add multiple items
      #   add_items [
      #     { title: 'star', character: '⭐' },
      #     { title: 'heart', character: '❤️' }
      #   ]
      def add_items(collection)
        collection.each do |item|
          @items << item.slice(:title, :character)
        end
      end

      # Add multiple characters to the group
      #
      # @param items [Array<Hash>] Array of character definitions
      def add_characters(items)
        items.each do |item|
          @items << item.slice(:title, :character)
        end
      end

      # Convert group configuration to hash
      #
      # @return [Hash] Group configuration hash
      def to_h
        {
          name: @name,
          items: @items,
          options: label ? { label: label } : {}
        }
      end
    end

    # Initialize a new special characters builder
    #
    # @example Create new builder
    #   SpecialCharactersBuilder.new
    def initialize
      @groups = []
      @order = []
      @packs_plugins = []
    end

    # Define a new special characters group
    #
    # @param name [String] Name of the group
    # @param items [Array<Hash>] Optional array of character items
    # @param label [String, nil] Optional display label
    # @yield Group configuration block
    # @return [Group] Created group instance
    # @example Define group with items array
    #   group 'Emoji',
    #         items: [
    #           { title: 'smiley', character: '😊' },
    #           { title: 'heart', character: '❤️' }
    #         ],
    #         label: 'Emoticons'
    # @example Define group with block
    #   group 'Emoji', label: 'Emoticons' do
    #     item 'smiley', '😊'
    #     item 'heart', '❤️'
    #   end
    def group(name, items: [], label: nil, &block)
      group = Group.new(name, label: label)
      group.add_characters(items) if items.any?
      group.instance_eval(&block) if block_given?
      @groups << group
      group
    end

    # Enable special characters packs
    #
    # @param names [Array<Symbol, String>] Pack names to enable
    # @example Enable essential and extended characters
    #   packs :Text, :Currency, :Mathematical
    def packs(*names)
      names.each do |name|
        plugin_name = "SpecialCharacters#{name.to_s.capitalize}"
        @packs_plugins << plugin_name
      end
    end

    # Set the display order of character groups
    #
    # @param categories [Array<Symbol, String>] Category names in desired order
    # @example Set display order
    #   order :Text, :Mathematical, 'Currency', :Emoji
    def order(*categories)
      @order = categories.map(&:to_s)
    end

    # Convert builder configuration to hash
    #
    # @return [Hash] Complete special characters configuration
    def to_h
      {
        groups: @groups.map(&:to_h),
        order: @order,
        packs: @packs_plugins
      }
    end
  end
end
