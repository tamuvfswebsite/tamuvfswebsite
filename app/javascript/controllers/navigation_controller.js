import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="navigation"
export default class extends Controller {
  static targets = ['menu', 'toggle']

  connect() {
    // Ensure menu is closed on load
    this.close()

    // Close menu when clicking outside
    this.boundCloseOnClickOutside = this.closeOnClickOutside.bind(this)
    document.addEventListener('click', this.boundCloseOnClickOutside)

    // Close menu on escape key
    this.boundCloseOnEscape = this.closeOnEscape.bind(this)
    document.addEventListener('keydown', this.boundCloseOnEscape)
  }

  disconnect() {
    // Clean up event listeners
    document.removeEventListener('click', this.boundCloseOnClickOutside)
    document.removeEventListener('keydown', this.boundCloseOnEscape)
  }

  toggle(event) {
    event.stopPropagation()

    if (this.menuTarget.classList.contains('open')) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.menuTarget.classList.add('open')
    this.toggleTarget.setAttribute('aria-expanded', 'true')
  }

  close() {
    this.menuTarget.classList.remove('open')
    this.toggleTarget.setAttribute('aria-expanded', 'false')
  }

  closeOnClickOutside(event) {
    // Don't close if clicking inside the navbar
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === 'Escape' && this.menuTarget.classList.contains('open')) {
      this.close()
      this.toggleTarget.focus()
    }
  }

  // Close menu when a nav link is clicked (for mobile)
  closeMenu() {
    if (window.innerWidth <= 768) {
      this.close()
    }
  }
}
