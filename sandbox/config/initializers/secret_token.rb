# frozen_string_literal: true

Sandbox::Application.config.secret_key_base = Digest::SHA1.hexdigest([Time.zone.now, rand].join)
