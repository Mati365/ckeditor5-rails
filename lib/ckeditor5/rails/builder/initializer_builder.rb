# frozen_string_literal: true

module CKEditor5::Rails::Builder
  class InitializerBuilder
    attr_reader :id, :config

    def initialize(config)
      @id = SecureRandom.uuid
      @config = config
    end

    def to_js
      <<-JS
        import { ClassicEditor } from 'ckeditor5';

        ClassicEditor
          .create(document.getElementById('#{id}'), #{config.to_json})
          .catch(error => {
            console.error(error);
          });
      JS
    end
  end
end
