import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["response", "responseStream", "submit", "submitStream"]

  connect() {
    this.element.addEventListener("turbo:submit-start", (event) => {
      const isStreamForm = event.target.dataset.testid === 'rails-form-stream'
      const submitButton = isStreamForm ? this.submitStreamTarget : this.submitTarget

      submitButton.disabled = true
      submitButton.textContent = "Saving..."
    })

    this.element.addEventListener("turbo:submit-end", (event) => {
      const isStreamForm = event.target.dataset.testid === 'rails-form-stream'
      const submitButton = isStreamForm ? this.submitStreamTarget : this.submitTarget
      const responseElement = isStreamForm ? this.responseStreamTarget : this.responseTarget

      submitButton.disabled = false
      submitButton.textContent = "Save"
      responseElement.style.display = 'block'
    })
  }
}
