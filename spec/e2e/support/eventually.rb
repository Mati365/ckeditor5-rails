# frozen_string_literal: true

# Add eventually helper for async operations
def eventually(timeout: 5, delay: 0.1)
  deadline = Time.zone.now + timeout
  loop do
    yield
    break
  rescue RSpec::Expectations::ExpectationNotMetError, StandardError => e
    raise e if Time.zone.now >= deadline

    sleep delay
  end
end
