// Simple loading indicator - just handles button states on form submit

document.addEventListener('DOMContentLoaded', function() {
  // Add spinner to disabled submit buttons
  document.addEventListener('submit', function(event) {
    const form = event.target
    if (form.tagName === 'FORM') {
      const submitButton = form.querySelector('input[type="submit"], button[type="submit"]')
      if (submitButton) {
        submitButton.disabled = true
      }
    }
  })
})
