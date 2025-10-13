require 'rails_helper'

RSpec.describe 'Users', type: :request do
  before do
    # Skip the authentication entirely for tests
    allow_any_instance_of(UsersController).to receive(:ensure_admin_user).and_return(true)
  end

  # Note: Authorization tests for /users endpoint are in application_controller_spec.rb

  describe 'sponsor role' do
    it 'allows assigning sponsor role to users' do
      user = create_user(role: 'user')
      # Stub the update method's self-edit check to always allow changes
      controller = UsersController.new
      allow(UsersController).to receive(:new).and_return(controller)
      allow(controller).to receive(:current_admin).and_return(double('Admin', uid: 'different_uid'))

      patch "/users/#{user.id}", params: { user: { role: 'sponsor' } }
      user.reload
      expect(user.role).to eq('sponsor')
    end
  end

  describe 'organizational roles' do
    let(:ai_team) { OrganizationalRole.create!(name: 'AI Team') }

    it 'allows assigning organizational role to users' do
      user = create_user
      # Stub the update method's self-edit check to always allow changes
      controller = UsersController.new
      allow(UsersController).to receive(:new).and_return(controller)
      allow(controller).to receive(:current_admin).and_return(double('Admin', uid: 'different_uid'))

      patch "/users/#{user.id}", params: { user: { organizational_role_id: ai_team.id } }
      user.reload
      expect(user.organizational_role).to eq(ai_team)
    end
  end

  describe 'self-edit prevention' do
    it 'prevents admin from changing their own role' do
      admin_user = create_user(role: 'admin', uid: 'admin123')
      controller = UsersController.new
      allow(UsersController).to receive(:new).and_return(controller)
      allow(controller).to receive(:current_admin).and_return(double('Admin', uid: 'admin123'))

      patch "/users/#{admin_user.id}", params: { user: { role: 'user' } }
      admin_user.reload

      expect(admin_user.role).to eq('admin')
      expect(response).to redirect_to(admin_user)
    end

    it 'allows admin to change their own organizational role' do
      ai_team = OrganizationalRole.create!(name: 'AI Team')
      admin_user = create_user(role: 'admin', uid: 'admin123')
      controller = UsersController.new
      allow(UsersController).to receive(:new).and_return(controller)
      allow(controller).to receive(:current_admin).and_return(double('Admin', uid: 'admin123'))

      patch "/users/#{admin_user.id}", params: { user: { organizational_role_id: ai_team.id } }
      admin_user.reload

      expect(admin_user.organizational_role).to eq(ai_team)
    end
  end
end
