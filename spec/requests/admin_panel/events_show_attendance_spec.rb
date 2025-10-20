require 'rails_helper'

RSpec.describe 'AdminPanel::Events show attendance and RSVPs', type: :request do
  let!(:event) do
    Event.create!(title: 'Workshop', description: 'desc', event_date: 1.day.from_now, location: 'Lab', capacity: 20,
                  attendance_points: 2, is_published: true)
  end
  let!(:user) { create_user(email: 'rsvpuser@test.com') }

  before do
    # Sign in as an admin (using the same user for convenience)
    sign_in_as_admin(user)
  end

  it 'shows RSVP counts and attendance stats (sunny)' do
    EventRsvp.create!(event: event, user: user, status: 'yes')
    Attendance.create!(event: event, user: user, checked_in_at: Time.current)

    get "/admin_panel/events/#{event.id}"
    expect(response).to have_http_status(:success)
    expect(response.body).to include('RSVP counts')
    expect(response.body).to include('Yes: 1')
    expect(response.body).to include('Attendance Stats:')
    expect(response.body).to include('1 attended out of 1 RSVPs')
  end

  it 'handles no RSVPs and no attendance (rainy)' do
    get "/admin_panel/events/#{event.id}"
    expect(response).to have_http_status(:success)
    expect(response.body).to include('RSVP counts')
    expect(response.body).to include('Yes: 0')
    expect(response.body).to include('No RSVPs yet')
    expect(response.body).to include('No attendees have checked in yet')
  end
end
