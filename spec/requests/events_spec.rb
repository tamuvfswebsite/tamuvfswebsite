require 'rails_helper'

RSpec.describe 'Events', type: :request do
  describe 'GET /events' do
    it 'returns http success' do
      get '/events'
      expect(response).to have_http_status(:success)
    end

    it 'displays only published future events' do
      Event.create!(
        title: 'Published Future Event',
        event_date: 1.day.from_now,
        location: 'Test',
        capacity: 50,
        is_published: true
      )
      Event.create!(
        title: 'Unpublished Future Event',
        event_date: 1.day.from_now,
        location: 'Test',
        capacity: 50,
        is_published: false
      )
      # Create as future, then update to past to bypass validation
      published_past = Event.create!(
        title: 'Published Past Event',
        event_date: 1.day.from_now,
        location: 'Test',
        capacity: 50,
        is_published: true
      )
      published_past.update_column(:event_date, 1.day.ago)

      get '/events'

      expect(response.body).to include('Published Future Event')
      expect(response.body).not_to include('Unpublished Future Event')
      expect(response.body).not_to include('Published Past Event')
    end
  end

  describe 'GET /events/:id' do
    it 'returns http success for a published event' do
      event = Event.create!(
        title: 'Test Event',
        event_date: 1.day.from_now,
        location: 'Test',
        capacity: 50,
        is_published: true
      )
      get "/events/#{event.id}"
      expect(response).to have_http_status(:success)
    end

    it 'raises error for unpublished event' do
      event = Event.create!(
        title: 'Unpublished Event',
        event_date: 1.day.from_now,
        location: 'Test',
        capacity: 50,
        is_published: false
      )

      # In test environment, Rails rescues RecordNotFound and returns 404
      get "/events/#{event.id}"
      expect(response).to have_http_status(:not_found)
    end
  end
end
