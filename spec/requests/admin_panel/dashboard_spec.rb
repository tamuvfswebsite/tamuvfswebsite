require 'rails_helper'

RSpec.describe 'AdminPanel::Dashboards', type: :request do
  before do
    # Skip the authentication entirely for tests
    allow_any_instance_of(AdminPanel::BaseController).to receive(:ensure_admin_user).and_return(true)
  end

  describe 'GET /index' do
    it 'returns http success' do
      get '/admin_panel/dashboard'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /leaderboard' do
    it 'returns http success' do
      get '/admin_panel/leaderboard'
      expect(response).to have_http_status(:success)
    end

    it 'orders users by points descending, then by last name and first name ascending' do
      User.create!(google_uid: SecureRandom.uuid, email: 'user1@example.com', first_name: 'Alice',
                   last_name: 'Smith', points: 100)
      User.create!(google_uid: SecureRandom.uuid, email: 'user2@example.com', first_name: 'Bob',
                   last_name: 'Jones', points: 200)
      User.create!(google_uid: SecureRandom.uuid, email: 'user3@example.com', first_name: 'Charlie',
                   last_name: 'Brown', points: 100)

      get '/admin_panel/leaderboard'

      expect(response).to have_http_status(:success)
      # Check the order in the response body
      expect(response.body.index('Bob')).to be < response.body.index('Charlie')
      expect(response.body.index('Charlie')).to be < response.body.index('Alice')
    end
  end
end
