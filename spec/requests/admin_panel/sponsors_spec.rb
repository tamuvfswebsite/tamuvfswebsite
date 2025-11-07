require 'rails_helper'

RSpec.describe 'AdminPanel::Sponsors', type: :request do
  before do
    # Skip authentication for tests
    allow_any_instance_of(ApplicationController).to receive(:admin_user?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('AdminUser'))
  end

  describe 'GET /index' do
    it 'returns http success' do
      get '/admin_panel/sponsors'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    it 'returns http success' do
      sponsor = Sponsor.create!(
        company_name: 'Test Co',
        website: 'https://example.com',
        tier: 'Gold',
        contact_email: 'contact@example.com',
        phone_number: '123-456-7890',
        company_description: 'A great test sponsor.'
      )
      get "/admin_panel/sponsors/#{sponsor.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /new' do
    it 'returns http success' do
      get '/admin_panel/sponsors/new'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /edit' do
    it 'returns http success' do
      sponsor = Sponsor.create!(
        company_name: 'Test Co',
        website: 'https://example.com',
        tier: 'Gold',
        contact_email: 'contact@example.com',
        phone_number: '123-456-7890',
        company_description: 'A great test sponsor.'
      )
      get "/admin_panel/sponsors/#{sponsor.id}/edit"
      expect(response).to have_http_status(:success)
    end
  end
end
