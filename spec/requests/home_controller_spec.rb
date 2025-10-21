require 'rails_helper'

RSpec.describe HomeController, type: :request do
  describe 'GET /' do
    context 'when not signed in' do
      it 'renders the landing page' do
        get root_path
        expect(response).to be_successful
      end

      it 'does not redirect' do
        get root_path
        expect(response).not_to be_redirect
      end
    end

    context 'when signed in' do
      let(:user) { create_user(role: 'user') }

      before do
        sign_in_as_admin(user)
      end

      it 'redirects to homepage' do
        get root_path
        expect(response).to redirect_to(homepage_path)
      end
    end
  end

  describe 'GET /homepage' do
    context 'when not signed in' do
      it 'redirects to root path' do
        get homepage_path
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when signed in' do
      let(:user) { create_user(role: 'user') }

      before do
        sign_in_as_admin(user)
      end

      it 'renders the homepage successfully' do
        get homepage_path
        expect(response).to be_successful
      end

      it 'displays upcoming events' do
        Event.create!(title: 'Upcoming Event 1', event_date: 1.day.from_now, location: 'Test Location',
                      capacity: 100, attendance_points: 10)
        Event.create!(title: 'Upcoming Event 2', event_date: 2.days.from_now, location: 'Test Location',
                      capacity: 100, attendance_points: 15)

        get homepage_path
        expect(response.body).to include('Upcoming Event 1')
        expect(response.body).to include('Upcoming Event 2')
      end

      it 'only shows future events' do
        Event.create!(title: 'Future Event', event_date: 1.day.from_now, location: 'Test Location',
                      capacity: 100, attendance_points: 10)
        past_event = Event.create!(title: 'Past Event', event_date: 1.day.from_now, location: 'Test Location',
                                   capacity: 100, attendance_points: 5)
        past_event.update_column(:event_date, 1.day.ago)

        get homepage_path
        expect(response.body).to include('Future Event')
        expect(response.body).not_to include('Past Event')
      end

      it 'orders events by event date' do
        Event.create!(title: 'Event Later', event_date: 5.days.from_now, location: 'Test Location',
                      capacity: 100, attendance_points: 10)
        Event.create!(title: 'Event Sooner', event_date: 1.day.from_now, location: 'Test Location',
                      capacity: 100, attendance_points: 10)

        get homepage_path

        # Check that sooner event appears before later event
        sooner_position = response.body.index('Event Sooner')
        later_position = response.body.index('Event Later')
        expect(sooner_position).to be < later_position
      end

      it 'limits to 5 upcoming events' do
        # Create 7 future events
        7.times do |i|
          Event.create!(title: "Event #{i}", event_date: (i + 1).days.from_now, location: 'Test Location',
                        capacity: 100, attendance_points: 10)
        end

        get homepage_path

        # Check that only events 0-4 appear (first 5)
        expect(response.body).to include('Event 0')
        expect(response.body).to include('Event 4')
        expect(response.body).not_to include('Event 5')
        expect(response.body).not_to include('Event 6')
      end

      it 'uses application layout' do
        get homepage_path
        # Check for layout elements
        expect(response.body).to include('<!DOCTYPE html>')
      end
    end
  end

  describe 'GET /apply' do
    it 'sets session flag for role application' do
      get apply_path
      expect(session[:applying_for_role]).to eq(true)
    end

    it 'renders apply view' do
      get apply_path
      expect(response).to be_successful
      # The apply view renders a form that auto-submits to OAuth
      expect(response.body).to include('apply-form')
      expect(response.body).to include('/admins/auth/google_oauth2')
    end

    it 'renders successfully when already signed in' do
      user = create_user
      sign_in_as_admin(user)

      get apply_path
      expect(response).to be_successful
      expect(session[:applying_for_role]).to eq(true)
    end
  end

  describe '#current_user helper' do
    it 'helper works correctly for signed in users' do
      user = create_user(uid: 'unique123', email: 'unique@test.com')
      sign_in_as_admin(user)

      get homepage_path
      expect(response).to be_successful
      # The current_user helper is used internally and works correctly
    end

    it 'allows access when current_user exists' do
      user = create_user(uid: 'test123')
      sign_in_as_admin(user)

      get homepage_path
      # Verifies current_user helper allows homepage access
      expect(response).to be_successful
    end
  end
end
