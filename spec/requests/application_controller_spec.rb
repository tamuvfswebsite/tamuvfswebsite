require 'rails_helper'

RSpec.describe ApplicationController, type: :request do
  describe 'authentication and authorization' do
    it 'redirects non-authenticated users from admin pages' do
      allow_any_instance_of(ApplicationController).to receive(:admin_signed_in?).and_return(false)

      get '/users'
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include('Admin privileges required')
    end

    it 'redirects non-admin users (regular users) from admin pages' do
      # Simulate signed in but not admin role
      admin = double('Admin', uid: 'user123')
      allow_any_instance_of(ApplicationController).to receive(:admin_signed_in?).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:current_admin).and_return(admin)

      # Create user with non-admin role
      create_user(role: 'user', uid: 'user123')

      get '/users'
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include('Admin privileges required')
    end

    it 'allows admin users to access admin pages' do
      admin = double('Admin', uid: 'admin123')
      allow_any_instance_of(ApplicationController).to receive(:admin_signed_in?).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:current_admin).and_return(admin)

      # Create user with admin role
      create_user(role: 'admin', uid: 'admin123')

      get '/users'
      expect(response).to have_http_status(:success)
    end

    it 'redirects sponsor users from admin pages (only admin role allowed)' do
      admin = double('Admin', uid: 'sponsor123')
      allow_any_instance_of(ApplicationController).to receive(:admin_signed_in?).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:current_admin).and_return(admin)

      # Create user with sponsor role
      create_user(role: 'sponsor', uid: 'sponsor123')

      get '/users'
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include('Admin privileges required')
    end
  end
end
