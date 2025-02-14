# frozen_string_literal: true

module CKEditor5::Rails::Plugins
  module Patches
  end
end

# Core plugins
require_relative 'plugins/simple_upload_adapter'
require_relative 'plugins/wproofreader'
require_relative 'plugins/special_characters_bootstrap'
require_relative 'plugins/custom_translations_loader'

# Plugin patches and fixes
require_relative 'plugins/patches/fix_color_picker_race_condition'
