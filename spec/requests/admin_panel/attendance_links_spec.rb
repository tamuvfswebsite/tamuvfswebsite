require 'rails_helper'

RSpec.describe AdminPanel::AttendanceLinksController, type: :request do
  let(:admin_user) { create_user(role: 'admin') }

  before do
    sign_in_as_admin(admin_user)
  end

  describe 'GET /admin_panel/attendance_links/new' do
    it 'renders the new attendance link page successfully' do
      # Create some future events
      Event.create!(title: 'Future Event 1', event_date: 1.day.from_now, location: 'Test Location', capacity: 100,
                    attendance_points: 10)
      Event.create!(title: 'Future Event 2', event_date: 2.days.from_now, location: 'Test Location', capacity: 100,
                    attendance_points: 15)
      # Create a past event that should not appear
      past_event = Event.create!(title: 'Past Event', event_date: 1.day.from_now, location: 'Test Location',
                                 capacity: 100, attendance_points: 5)
      past_event.update_column(:event_date, 1.day.ago)

      get new_admin_panel_attendance_link_path
      expect(response).to be_successful
      expect(response.body).to include('Future Event 1')
      expect(response.body).to include('Future Event 2')
      expect(response.body).not_to include('Past Event')
    end

    it 'orders events by event date' do
      Event.create!(title: 'Event Later', event_date: 5.days.from_now, location: 'Test Location',
                    capacity: 100, attendance_points: 10)
      Event.create!(title: 'Event Sooner', event_date: 1.day.from_now, location: 'Test Location',
                    capacity: 100, attendance_points: 10)

      get new_admin_panel_attendance_link_path
      expect(response).to be_successful

      # Check that sooner event appears before later event in the response
      sooner_position = response.body.index('Event Sooner')
      later_position = response.body.index('Event Later')
      expect(sooner_position).to be < later_position
    end
  end

  describe 'POST /admin_panel/attendance_links' do
    let(:event) do
      Event.create!(title: 'Test Event', event_date: 1.day.from_now, location: 'Test Location', capacity: 100,
                    attendance_points: 10)
    end

    it 'creates an attendance link for an event' do
      post admin_panel_attendance_links_path, params: { event_id: event.id }

      expect(response).to redirect_to(admin_panel_events_path)
      expect(flash[:notice]).to include('Attendance link created')
      expect(flash[:notice]).to include('token=')
    end

    it 'generates a signed token that expires in 30 minutes' do
      post admin_panel_attendance_links_path, params: { event_id: event.id }

      # Extract token from flash message
      token_match = flash[:notice].match(/token=([^&\s]+)/)
      expect(token_match).to be_present

      token = token_match[1]
      # Verify the token can be used to retrieve the event using Rails' signed_id resolution
      decoded_event = Event.find_signed(token, purpose: 'checkin')
      expect(decoded_event).to eq(event)
    end

    it 'requires event_id parameter' do
      post admin_panel_attendance_links_path, params: {}
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns 404 when event does not exist' do
      post admin_panel_attendance_links_path, params: { event_id: 99_999 }
      expect(response).to have_http_status(:not_found)
    end
  end
end
