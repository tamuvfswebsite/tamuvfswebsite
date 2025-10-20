require 'rails_helper'

RSpec.describe 'Check-ins', type: :request do
  let!(:event) do
    Event.create!(title: 'Meetup', description: 'desc', event_date: 1.hour.from_now, location: 'Room', capacity: 30,
                  attendance_points: 3, is_published: true)
  end
  let!(:user) { create_user }

  def token_for(event)
    event.signed_id(purpose: 'checkin', expires_in: 30.minutes)
  end

  describe 'sunny day - successful check-in awards points and creates attendance' do
    it 'creates an attendance and increments user points' do
      sign_in_as_admin(user)
      expect do
        post '/checkin', params: { token: token_for(event) }
      end.to change { Attendance.where(event: event, user: user).count }.by(1)

      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to include('Checked in!')
      user.reload
      expect(user.points).to eq(0 + event.attendance_points)
    end
  end

  describe 'rainy day - duplicate check-in and invalid token' do
    it 'prevents duplicate attendance and points on second check-in' do
      sign_in_as_admin(user)
      post '/checkin', params: { token: token_for(event) }
      user.reload
      first_points = user.points

      post '/checkin', params: { token: token_for(event) }
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to include('already checked in')
      user.reload
      expect(user.points).to eq(first_points)
      expect(Attendance.where(event: event, user: user).count).to eq(1)
    end

    it 'returns gone for invalid/expired token' do
      sign_in_as_admin(user)
      post '/checkin', params: { token: 'bogus' }
      expect(response).to have_http_status(:gone)
    end
  end
end
