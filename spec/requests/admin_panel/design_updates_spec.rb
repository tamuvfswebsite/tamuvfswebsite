require 'rails_helper'

RSpec.describe 'AdminPanel::DesignUpdates', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/admin_panel/design_updates/index'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /new' do
    it 'returns http success' do
      get '/admin_panel/design_updates/new'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /create' do
    it 'returns http success' do
      get '/admin_panel/design_updates/create'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /edit' do
    it 'returns http success' do
      get '/admin_panel/design_updates/edit'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /update' do
    it 'returns http success' do
      get '/admin_panel/design_updates/update'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /destroy' do
    it 'returns http success' do
      get '/admin_panel/design_updates/destroy'
      expect(response).to have_http_status(:success)
    end
  end
end
