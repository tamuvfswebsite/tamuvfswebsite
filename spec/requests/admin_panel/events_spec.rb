require 'rails_helper'

RSpec.describe 'AdminPanel::Events', type: :request do
  before do
    # Skip the authentication entirely for tests
    allow_any_instance_of(AdminPanel::BaseController).to receive(:ensure_admin_user).and_return(true)
  end

  describe 'GET /index' do
    it 'returns http success' do
      get '/admin_panel/events'
      expect(response).to have_http_status(:success)
    end

    it 'displays events correctly' do
      # Create events with future dates only (respecting your validation)
      Event.create!(title: 'Event 1', event_date: 1.day.from_now, description: 'Test', location: 'Test',
                    capacity: 50)
      Event.create!(title: 'Event 2', event_date: 2.days.from_now, description: 'Test', location: 'Test',
                    capacity: 50)

      get '/admin_panel/events'

      expect(response.body).to include('Event 1')
      expect(response.body).to include('Event 2')
    end
  end

  describe 'GET /show' do
    let(:event) do
      Event.create!(title: 'Test Event', event_date: 1.day.from_now, description: 'Test', location: 'Test',
                    capacity: 50)
    end

    it 'returns http success' do
      get "/admin_panel/events/#{event.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /new' do
    it 'returns http success' do
      get '/admin_panel/events/new'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new event and redirects' do
        event_params = { event: { title: 'Test Event', description: 'Test', event_date: 1.day.from_now,
                                  location: 'Test Location', capacity: 50 } }

        expect do
          post '/admin_panel/events', params: event_params
        end.to change(Event, :count).by(1)

        expect(response).to have_http_status(:redirect)
        expect(flash[:notice]).to eq('Event created successfully!')
      end
    end

    context 'with invalid parameters' do
      it 'renders new template with errors' do
        event_params = { event: { title: '' } } # Invalid - missing required fields

        expect do
          post '/admin_panel/events', params: event_params
        end.not_to change(Event, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'GET /edit' do
    let(:event) do
      Event.create!(title: 'Test Event', event_date: 1.day.from_now, description: 'Test', location: 'Test',
                    capacity: 50)
    end

    it 'returns http success' do
      get "/admin_panel/events/#{event.id}/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /update' do
    let(:event) do
      Event.create!(title: 'Test Event', event_date: 1.day.from_now, description: 'Test', location: 'Test',
                    capacity: 50)
    end

    context 'with valid parameters' do
      it 'updates the event and redirects' do
        patch "/admin_panel/events/#{event.id}", params: { event: { title: 'Updated Event' } }

        expect(response).to have_http_status(:redirect)
        expect(event.reload.title).to eq('Updated Event')
        expect(flash[:notice]).to eq('Event updated successfully!')
      end
    end

    context 'with invalid parameters' do
      it 'renders edit template with errors' do
        patch "/admin_panel/events/#{event.id}", params: { event: { title: '' } } # Invalid - empty title

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE /destroy' do
    let!(:event) do
      Event.create!(title: 'Test Event', event_date: 1.day.from_now, description: 'Test', location: 'Test',
                    capacity: 50)
    end

    it 'destroys the event and redirects' do
      expect do
        delete "/admin_panel/events/#{event.id}"
      end.to change(Event, :count).by(-1)

      expect(response).to have_http_status(:redirect)
      expect(flash[:notice]).to eq('Event deleted successfully!')
    end
  end
end
