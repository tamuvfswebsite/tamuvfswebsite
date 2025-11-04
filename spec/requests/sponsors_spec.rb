require 'rails_helper'

RSpec.describe 'Sponsors', type: :request do
  let(:user) do
    User.create!(
      email: 'sponsor@example.com',
      first_name: 'Sponsor',
      last_name: 'User',
      google_uid: '456',
      role: 'sponsor'
    )
  end

  let(:sponsor) do
    Sponsor.create!(
      company_name: 'TechCorp',
      website: 'https://techcorp.com',
      tier: 'Gold',
      contact_email: 'contact@techcorp.com',
      phone_number: '123-456-7890',
      company_description: 'A great tech company.',
      resume_access: true,
      users: [user]
    )
  end

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe 'GET /edit' do
    it 'returns http success' do
      get edit_sponsor_path(sponsor) # <- correct route helper
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /update' do
    it 'returns http success' do
      patch sponsor_path(sponsor), params: { sponsor: { company_name: 'Updated' } }
      expect(response).to have_http_status(:redirect) # update usually redirects
      expect(sponsor.reload.company_name).to eq('Updated')
    end
  end
end
