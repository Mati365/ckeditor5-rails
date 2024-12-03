# frozen_string_literal: true

module FormHelpers
  def setup_form_tracking(driver)
    driver.execute_script <<~JS
      window.lastSubmittedForm = null;

      document.addEventListener('submit', (e) => {
        if (!e.target.hasAttribute('data-turbo-frame')) {
          e.preventDefault();
        }

        window.lastSubmittedForm = e.target.id;
      });
    JS
  end
end

RSpec.configure do |config|
  config.include FormHelpers, type: :feature
end

RSpec::Matchers.define :be_invalid do
  match do |element|
    element[:validity] == 'false' ||
      element.evaluate_script('!this.validity.valid')
  end
end

RSpec::Matchers.define :have_been_submitted do
  match do |form|
    page.evaluate_script('window.lastSubmittedForm') == form['id']
  end
end

RSpec::Matchers.define :have_invisible_textarea do
  match do |element|
    element.has_css?('textarea', visible: :hidden)
  end
end
