require 'rails_helper'

RSpec.describe 'SponsorDashboards', type: :request do
  let(:user) do
    User.create!(
      email: 'test@example.com',
      first_name: 'Test',
      last_name: 'User',
      google_uid: '123',
      role: 'sponsor'
    )
  end

  let(:sponsor) do
    Sponsor.create!(
      company_name: 'TechCorp',
      website: 'https://techcorp.com',
      resume_access: true
    )
  end

  before do
    user.sponsors << sponsor
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe 'GET /index' do
    it 'returns http success' do
      get sponsor_dashboard_index_path
      expect(response).to have_http_status(:success)
    end

    it 'only shows the current user’s sponsor' do
      get sponsor_dashboard_index_path
      expect(response.body).to include('TechCorp')
      expect(response.body).not_to include('Other Sponsor')
    end
  end
end
