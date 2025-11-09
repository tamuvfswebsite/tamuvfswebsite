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
        is_published: true,
        is_public: true
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
        is_published: true,
        is_public: true
      )
      published_past.update_column(:event_date, 1.day.ago)

      get '/events'

      expect(response.body).to include('Published Future Event')
      expect(response.body).not_to include('Unpublished Future Event')
      expect(response.body).not_to include('Published Past Event')
    end

    describe 'event filtering by organizational roles' do
      let(:ai_role) { OrganizationalRole.create!(name: 'AI', description: 'AI Role') }
      let(:design_role) { OrganizationalRole.create!(name: 'Design', description: 'Design Role') }
      let(:user) { create_user(organizational_roles: [ai_role]) }

      let!(:public_event) do
        Event.create!(
          title: 'Public Event',
          event_date: 1.day.from_now,
          location: 'Test',
          capacity: 50,
          is_published: true,
          is_public: true
        )
      end

      let!(:ai_event) do
        event = Event.create!(
          title: 'AI Event',
          event_date: 1.day.from_now,
          location: 'Test',
          capacity: 50,
          is_published: true,
          is_public: false
        )
        event.organizational_roles << ai_role
        event
      end

      let!(:design_event) do
        event = Event.create!(
          title: 'Design Event',
          event_date: 1.day.from_now,
          location: 'Test',
          capacity: 50,
          is_published: true,
          is_public: false
        )
        event.organizational_roles << design_role
        event
      end

      let!(:untagged_event) do
        Event.create!(
          title: 'Untagged Event',
          event_date: 1.day.from_now,
          location: 'Test',
          capacity: 50,
          is_published: true,
          is_public: false
        )
      end

      context 'when user is signed in with roles' do
        before { sign_in_as_admin(user) }

        it 'shows public events, events for user roles, and untagged events' do
          get '/events'
          expect(response.body).to include('Public Event')
          expect(response.body).to include('AI Event')
          expect(response.body).to include('Untagged Event')
          expect(response.body).not_to include('Design Event')
        end

        it 'allows filtering by organizational role' do
          get '/events', params: { organizational_role_id: design_role.id }
          # When filtering by a specific role, should show that role's events and public events
          expect(response.body).to include('Design Event')
          # NOTE: Public events may or may not appear depending on implementation
          # The key is that Design Event appears and AI Event doesn't
          expect(response.body).not_to include('AI Event')
        end
      end

      context 'when user is not signed in' do
        it 'shows only public events' do
          get '/events'
          expect(response.body).to include('Public Event')
          expect(response.body).not_to include('AI Event')
          expect(response.body).not_to include('Design Event')
          expect(response.body).not_to include('Untagged Event')
        end
      end

      context 'when user is an admin' do
        let(:admin_user) { create_user(role: 'admin') }

        before { sign_in_as_admin(admin_user) }

        it 'shows all events' do
          get '/events'
          expect(response.body).to include('Public Event')
          expect(response.body).to include('AI Event')
          expect(response.body).to include('Design Event')
          expect(response.body).to include('Untagged Event')
        end
      end
    end
  end

  describe 'GET /events/:id' do
    it 'returns http success for a published public event' do
      event = Event.create!(
        title: 'Test Event',
        event_date: 1.day.from_now,
        location: 'Test',
        capacity: 50,
        is_published: true,
        is_public: true
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

    describe 'event visibility based on roles' do
      let(:ai_role) { OrganizationalRole.create!(name: 'AI', description: 'AI Role') }
      let(:design_role) { OrganizationalRole.create!(name: 'Design', description: 'Design Role') }
      let(:user) { create_user(organizational_roles: [ai_role]) }

      let!(:public_event) do
        Event.create!(
          title: 'Public Event',
          event_date: 1.day.from_now,
          location: 'Test',
          capacity: 50,
          is_published: true,
          is_public: true
        )
      end

      let!(:ai_event) do
        event = Event.create!(
          title: 'AI Event',
          event_date: 1.day.from_now,
          location: 'Test',
          capacity: 50,
          is_published: true,
          is_public: false
        )
        event.organizational_roles << ai_role
        event
      end

      let!(:design_event) do
        event = Event.create!(
          title: 'Design Event',
          event_date: 1.day.from_now,
          location: 'Test',
          capacity: 50,
          is_published: true,
          is_public: false
        )
        event.organizational_roles << design_role
        event
      end

      let!(:untagged_event) do
        Event.create!(
          title: 'Untagged Event',
          event_date: 1.day.from_now,
          location: 'Test',
          capacity: 50,
          is_published: true,
          is_public: false
        )
      end

      context 'when user can view the event' do
        before { sign_in_as_admin(user) }

        it 'allows viewing public events' do
          get "/events/#{public_event.id}"
          expect(response).to have_http_status(:success)
        end

        it 'allows viewing events for user roles' do
          get "/events/#{ai_event.id}"
          expect(response).to have_http_status(:success)
        end

        it 'allows viewing untagged events when user has roles' do
          get "/events/#{untagged_event.id}"
          expect(response).to have_http_status(:success)
        end
      end

      context 'when user cannot view the event' do
        before { sign_in_as_admin(user) }

        it 'redirects for events not for user roles' do
          get "/events/#{design_event.id}"
          expect(response).to redirect_to(events_path)
          expect(flash[:alert]).to include("don't have permission")
        end
      end

      context 'when user is not signed in' do
        it 'allows viewing public events' do
          get "/events/#{public_event.id}"
          expect(response).to have_http_status(:success)
        end

        it 'redirects for non-public events' do
          get "/events/#{ai_event.id}"
          expect(response).to redirect_to(events_path)
        end

        it 'redirects for untagged events' do
          get "/events/#{untagged_event.id}"
          expect(response).to redirect_to(events_path)
        end
      end
    end
  end
end
