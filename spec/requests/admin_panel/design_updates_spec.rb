require 'rails_helper'

RSpec.describe 'AdminPanel::DesignUpdates', type: :request do
  # Setup: Create an admin user and authenticate
  let(:admin_user) { User.create!(email: 'admin@example.com', google_uid: 'admin123', role: 'admin') }
  let(:design_update) do
    DesignUpdate.create!(
      title: 'Test Update',
      update_date: Date.today,
      pdf_file: fixture_file_upload('spec/fixtures/test.pdf', 'application/pdf')
    )
  end

  before do
    # Mock authentication
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin_user)
    allow_any_instance_of(ApplicationController).to receive(:admin_signed_in?).and_return(true)
  end

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

  describe 'POST /create' do
    it 'creates a new design update and redirects' do
      post '/admin_panel/design_updates', params: {
        design_update: {
          title: 'New Update',
          update_date: Date.today,
          pdf_file: fixture_file_upload('spec/fixtures/test.pdf', 'application/pdf')
        }
      }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(admin_panel_design_updates_path)
    end
  end

  describe 'GET /edit' do
    it 'returns http success' do
      get "/admin_panel/design_updates/#{design_update.id}/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /update' do
    it 'updates the design update and redirects' do
      patch "/admin_panel/design_updates/#{design_update.id}", params: {
        design_update: {
          title: 'Updated Title'
        }
      }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(admin_panel_design_updates_path)
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the design update and redirects' do
      delete "/admin_panel/design_updates/#{design_update.id}"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(admin_panel_design_updates_path)
    end
  end
end
