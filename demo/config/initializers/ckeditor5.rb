# frozen_string_literal: true

CKEditor5::Rails::Engine.configure do |config|
  config.presets.override :default do |preset|
    preset.menubar visible: false
  end
end
