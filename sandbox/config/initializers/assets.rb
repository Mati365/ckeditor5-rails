# frozen_string_literal: true

Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('app/assets/images')
Rails.application.config.assets.precompile += %w[cards/*.png]
