require 'rails_helper'

RSpec.describe 'admin_panel/events/form', type: :view do
  let(:event) do
    Event.new(title: 'Tech Talk', description: 'AI in 2025', event_date: Time.now + 1.day, location: 'MSC',
              capacity: 100, attendance_points: 5)
  end

  context 'sunny day' do
    it 'renders the form with correct fields' do
      assign(:event, event)
      render partial: 'admin_panel/events/form', locals: { event: event }

      expect(rendered).to have_selector('form')
      expect(rendered).to have_field('Event Title', with: 'Tech Talk')
      expect(rendered).to have_field('Event Description', text: 'AI in 2025')
      expect(rendered).to have_field('Event Location', with: 'MSC')
      expect(rendered).to have_field('Maximum Capacity', with: '100')
      expect(rendered).to have_field('Attendance Points', with: '5')
      expect(rendered).to have_button('Create Event').or have_button('Update Event')
    end
  end

  context 'rainy day' do
    it 'renders error messages when event has validation errors' do
      invalid_event = Event.new
      invalid_event.validate # triggers validation errors

      assign(:event, invalid_event)
      render partial: 'admin_panel/events/form', locals: { event: invalid_event }

      expect(rendered).to match(/error/i)
      expect(rendered).to match(/prohibited this event from being saved/i)
    end
  end
end
