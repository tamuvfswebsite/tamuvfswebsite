# Online Help and Context-Sensitive UX

This guide describes how to implement and maintain in-app, context-sensitive help. These elements live alongside views so users always have guidance.

Last updated: 2025-10-16

## Principles
- Keep help where users need it (tooltips, inline hints, “?” icons)
- Make it accessible (ARIA labels, focusable targets)
- Keep it version-controlled (partials within app/views)

## Patterns

### 1) Tooltip with title attribute
```erb
<%= label_tag :event_name, 'Event name' %>
<span class="help" title="Name visible on the Events page.">?</span>
```

### 2) Help partials per view
Create partials to explain forms/flows and render them where needed.
```erb
<!-- app/views/shared/_help_event_form.html.erb -->
<div class="help-box">
  <h3>Creating an Event</h3>
  <ul>
    <li>Title: the name shown publicly</li>
    <li>Date/Time: in local timezone</li>
    <li>Description: supports basic formatting</li>
  </ul>
</div>

<!-- In app/views/admin_panel/events/_form.html.erb -->
<%= render 'shared/help_event_form' %>
```

### 3) Stimulus popover for “?” icons
```erb
<!-- app/views/shared/_help_icon.html.erb -->
<span data-controller="popover" data-popover-content-value="<p>Upload a single PDF resume. Max 2MB.</p>" role="button" tabindex="0">?</span>
```
```js
// app/javascript/controllers/popover_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { content: String }

  connect() {
    this.element.addEventListener('click', () => this.show())
    this.element.addEventListener('keydown', (e) => { if (e.key === 'Enter') this.show() })
  }

  show() {
    // naive popover; replace with Tippy.js or similar if desired
    const div = document.createElement('div')
    div.className = 'popover'
    div.innerHTML = this.contentValue
    document.body.appendChild(div)
    const rect = this.element.getBoundingClientRect()
    div.style.position = 'absolute'
    div.style.left = `${rect.left}px`
    div.style.top = `${rect.bottom + 4}px`
    const close = () => { div.remove(); document.removeEventListener('click', close) }
    setTimeout(() => document.addEventListener('click', close), 0)
  }
}
```

### 4) Error help
Attach explanations near validation errors.
```erb
<% if @resume.errors.any? %>
  <div class="alert alert-danger">
    <p>There were problems with your upload:</p>
    <ul>
      <% @resume.errors.full_messages.each do |m| %>
        <li><%= m %></li>
      <% end %>
    </ul>
    <p>Only PDF files up to 2MB are accepted.</p>
  </div>
<% end %>
```

## Accessibility
- Ensure tab focus reaches help icons
- Provide ARIA attributes for popovers and dialogs
- Don’t rely solely on hover; support click/keyboard

## Maintenance
- Keep help partials near their views
- Include `REFERENCES.md` link on a central “Help” page
- Review help content during feature changes
