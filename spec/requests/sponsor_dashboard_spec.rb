require 'rails_helper'

RSpec.describe 'SponsorDashboards', type: :request do
  before do
    # Skip the authentication entirely for tests
    allow_any_instance_of(SponsorDashboardController).to receive(:ensure_sponsor_user).and_return(true)
  end

  describe 'GET /index' do
    it 'returns http success' do
      get '/sponsor_dashboard/index'
      expect(response).to have_http_status(:success)
    end
  end
end
