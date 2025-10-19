require 'rails_helper'

RSpec.describe 'AdminPanel::Sponsors', type: :request do
  before do
    # Skip the authentication entirely for tests
    allow_any_instance_of(AdminPanel::BaseController).to receive(:ensure_admin_user).and_return(true)
  end

  describe 'GET /index' do
    it 'returns http success' do
      get '/admin_panel/sponsors/index'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    it 'returns http success' do
      get '/admin_panel/sponsors/show'
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
      get '/admin_panel/sponsors/edit'
      expect(response).to have_http_status(:success)
    end
  end
end
