require 'rails_helper'

RSpec.describe 'Event RSVPs', type: :request do
  let!(:event) do
    Event.create!(title: 'Tech Talk', description: 'desc', event_date: 2.days.from_now, location: 'Hall', capacity: 100,
                  attendance_points: 1, is_published: true)
  end
  let!(:user) { create_user }

  describe 'sunny day - create/update RSVP' do
    it 'creates RSVP yes when signed in and event open' do
      sign_in_as_admin(user)

      post "/events/#{event.id}/rsvp", params: { status: 'yes' }
      expect(response).to redirect_to(event)
      expect(EventRsvp.where(event: event, user: user, status: 'yes')).to exist

      # update to maybe
      patch "/events/#{event.id}/rsvp", params: { status: 'maybe' }
      expect(response).to redirect_to(event)
      expect(EventRsvp.where(event: event, user: user, status: 'maybe')).to exist
    end
  end

  describe 'rainy day - auth and closed event' do
    it 'redirects to sign in when not logged in' do
      post "/events/#{event.id}/rsvp", params: { status: 'yes' }
      expect(response).to redirect_to(new_admin_session_path)
    end

    it 'disallows RSVP when event is closed' do
      past_event = Event.create!(title: 'Past', description: 'd', event_date: 1.day.ago, location: 'Hall',
                                 capacity: 50, attendance_points: 1, is_published: true)
      sign_in_as_admin(user)

      post "/events/#{past_event.id}/rsvp", params: { status: 'yes' }
      expect(response).to redirect_to(past_event)
      follow_redirect!
      expect(response.body).to include('RSVP is closed')
      expect(EventRsvp.where(event: past_event, user: user)).not_to exist
    end
  end
end
