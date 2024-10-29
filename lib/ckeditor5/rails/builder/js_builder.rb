# frozen_string_literal: true

module CKEditor5::Rails::Builder
  module JsBuilder
    def self.create_esm_default_import(import_name, import_as)
      "import #{import_as} from '#{import_name}';"
    end

    def self.create_esm_import(import_name, imports)
      "import { #{imports.join(', ')} } from '#{import_name}';"
    end

    def self.create_window_import(window_entry, name)
      "const #{name} = window['#{window_entry}'];"
    end
  end
end
