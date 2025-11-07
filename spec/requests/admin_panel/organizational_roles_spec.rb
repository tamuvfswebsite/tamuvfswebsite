require 'rails_helper'

RSpec.describe 'AdminPanel::OrganizationalRoles', type: :request do
  before do
    # Skip the authentication entirely for tests
    allow_any_instance_of(AdminPanel::BaseController).to receive(:ensure_admin_user).and_return(true)
  end

  describe 'authorization' do
    it 'requires admin authentication to access organizational roles' do
      # Remove authentication stub for this test
      allow_any_instance_of(AdminPanel::BaseController).to receive(:ensure_admin_user).and_call_original
      allow_any_instance_of(ApplicationController).to receive(:admin_signed_in?).and_return(false)

      get '/admin_panel/organizational_roles'
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include('Admin privileges required')
    end

    it 'requires admin role (not just regular user) to access organizational roles' do
      # Remove authentication stub for this test
      allow_any_instance_of(AdminPanel::BaseController).to receive(:ensure_admin_user).and_call_original
      admin = double('Admin', uid: 'user123')
      allow_any_instance_of(ApplicationController).to receive(:admin_signed_in?).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:current_admin).and_return(admin)

      # Create user with non-admin role
      create_user(role: 'user', uid: 'user123')

      get '/admin_panel/organizational_roles'
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include('Admin privileges required')
    end
  end

  describe 'CRUD operations' do
    it 'creates a new organizational role' do
      expect do
        post '/admin_panel/organizational_roles', params: {
          organizational_role: { name: 'Sales Team' }
        }
      end.to change(OrganizationalRole, :count).by(1)

      expect(OrganizationalRole.last.name).to eq('Sales Team')
    end

    it 'updates an organizational role' do
      role = OrganizationalRole.create!(name: 'Finance Team')
      patch "/admin_panel/organizational_roles/#{role.id}", params: {
        organizational_role: { name: 'Accounting Team' }
      }
      role.reload
      expect(role.name).to eq('Accounting Team')
    end

    it 'updates an organizational role with JSON format' do
      role = OrganizationalRole.create!(name: 'Finance Team')
      patch "/admin_panel/organizational_roles/#{role.id}",
            params: { organizational_role: { name: 'Accounting Team' } },
            as: :json

      expect(response).to have_http_status(:ok)
      role.reload
      expect(role.name).to eq('Accounting Team')
    end

    it 'renders JSON error when update fails' do
      role = OrganizationalRole.create!(name: 'Finance Team')
      patch "/admin_panel/organizational_roles/#{role.id}",
            params: { organizational_role: { name: '' } },
            as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)).to have_key('name')
    end

    it 'deletes an organizational role and removes user associations' do
      role = OrganizationalRole.create!(name: 'Operations Team')
      user = create_user(organizational_roles: [role])

      delete "/admin_panel/organizational_roles/#{role.id}"
      user.reload

      expect(user.organizational_roles).to be_empty
      expect(OrganizationalRole.find_by(id: role.id)).to be_nil
    end

    it 'prevents creating duplicate organizational role names' do
      OrganizationalRole.create!(name: 'Engineering Team')

      expect do
        post '/admin_panel/organizational_roles', params: {
          organizational_role: { name: 'Engineering Team' }
        }
      end.not_to change(OrganizationalRole, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'prevents creating organizational role without name' do
      expect do
        post '/admin_panel/organizational_roles', params: {
          organizational_role: { name: '' }
        }
      end.not_to change(OrganizationalRole, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
