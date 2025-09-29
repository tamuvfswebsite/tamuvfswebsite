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
end