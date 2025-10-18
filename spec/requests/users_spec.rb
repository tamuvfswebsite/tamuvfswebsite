require 'rails_helper'

RSpec.describe 'Users', type: :request do
  before do
    # Skip the authentication entirely for tests
    allow_any_instance_of(UsersController).to receive(:ensure_admin_user).and_return(true)
  end

  # NOTE: Authorization tests for /users endpoint are in application_controller_spec.rb

  describe 'profile viewing authorization' do
    it 'allows users to view their own profile' do
      user = create_user(role: 'user', uid: 'user123')

      # Bypass admin check but keep own profile check
      allow_any_instance_of(UsersController).to receive(:ensure_admin_user)
      controller = UsersController.new
      allow(UsersController).to receive(:new).and_return(controller)
      allow(controller).to receive(:admin_user?).and_return(false)
      allow(controller).to receive(:admin_signed_in?).and_return(true)
      allow(controller).to receive(:current_admin).and_return(double('Admin', uid: 'user123'))

      get "/users/#{user.id}"
      expect(response).to have_http_status(:success)
    end

    it 'prevents users from viewing other users profiles' do
      create_user(role: 'user', uid: 'user123')
      user2 = create_user(role: 'user', uid: 'user456')

      # Bypass admin check but keep own profile check
      allow_any_instance_of(UsersController).to receive(:ensure_admin_user)
      controller = UsersController.new
      allow(UsersController).to receive(:new).and_return(controller)
      allow(controller).to receive(:admin_user?).and_return(false)
      allow(controller).to receive(:admin_signed_in?).and_return(true)
      allow(controller).to receive(:current_admin).and_return(double('Admin', uid: 'user123'))

      get "/users/#{user2.id}"
      expect(response).to redirect_to(homepage_path)
      expect(flash[:alert]).to include('You can only view your own profile')
    end

    it 'allows admins to view any user profile' do
      create_user(role: 'admin', uid: 'admin123')
      other_user = create_user(role: 'user', uid: 'user456')

      # Bypass admin check, admin can view anyone
      allow_any_instance_of(UsersController).to receive(:ensure_admin_user)
      controller = UsersController.new
      allow(UsersController).to receive(:new).and_return(controller)
      allow(controller).to receive(:admin_user?).and_return(true)

      get "/users/#{other_user.id}"
      expect(response).to have_http_status(:success)
    end
  end

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
    let(:design_team) { OrganizationalRole.create!(name: 'Design Team') }

    it 'allows assigning multiple organizational roles to users' do
      user = create_user
      # Stub the update method's self-edit check to always allow changes
      controller = UsersController.new
      allow(UsersController).to receive(:new).and_return(controller)
      allow(controller).to receive(:current_admin).and_return(double('Admin', uid: 'different_uid'))

      patch "/users/#{user.id}", params: { user: { organizational_role_ids: [ai_team.id, design_team.id] } }
      user.reload
      expect(user.organizational_roles).to include(ai_team, design_team)
      expect(user.organizational_roles.count).to eq(2)
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

    it 'allows admin to change their own organizational roles' do
      ai_team = OrganizationalRole.create!(name: 'AI Team')
      design_team = OrganizationalRole.create!(name: 'Design Team')
      admin_user = create_user(role: 'admin', uid: 'admin123')
      controller = UsersController.new
      allow(UsersController).to receive(:new).and_return(controller)
      allow(controller).to receive(:current_admin).and_return(double('Admin', uid: 'admin123'))

      patch "/users/#{admin_user.id}", params: { user: { organizational_role_ids: [ai_team.id, design_team.id] } }
      admin_user.reload

      expect(admin_user.organizational_roles).to include(ai_team, design_team)
      expect(admin_user.organizational_roles.count).to eq(2)
    end
  end

  describe 'points display' do
    it 'displays user points on the index page' do
      user = create_user(email: 'points_user@test.com')
      user.update!(points: 42)

      get '/users'
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Points:')
      expect(response.body).to include('42')
    end

    it 'displays user points on the show page' do
      user = create_user(email: 'points_user@test.com')
      user.update!(points: 100)

      controller = UsersController.new
      allow(UsersController).to receive(:new).and_return(controller)
      allow(controller).to receive(:admin_user?).and_return(true)

      get "/users/#{user.id}"
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Points:')
      expect(response.body).to include('100')
    end

    it 'displays zero points for users with no points' do
      create_user(email: 'zero_points@test.com')

      get '/users'
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Points:')
      expect(response.body).to include('0')
    end
  end

  describe 'filtering by organizational role' do
    let(:ai_team) { OrganizationalRole.create!(name: 'AI Team') }
    let(:design_team) { OrganizationalRole.create!(name: 'Design Team') }

    it 'shows all users when no filter is applied' do
      create_user(organizational_roles: [ai_team], email: 'user1@test.com')
      create_user(organizational_roles: [design_team], email: 'user2@test.com')
      create_user(email: 'user3@test.com')

      get '/users'
      expect(response).to have_http_status(:success)
      expect(response.body).to include('user1@test.com')
      expect(response.body).to include('user2@test.com')
      expect(response.body).to include('user3@test.com')
    end

    it 'filters users by organizational role' do
      create_user(organizational_roles: [ai_team], email: 'aiuser@test.com')
      create_user(organizational_roles: [design_team], email: 'designuser@test.com')
      create_user(organizational_roles: [ai_team, design_team], email: 'bothuser@test.com')
      create_user(email: 'noorguser@test.com')

      get '/users', params: { organizational_role_id: ai_team.id }
      expect(response).to have_http_status(:success)
      expect(response.body).to include('aiuser@test.com')
      expect(response.body).to include('bothuser@test.com')
      expect(response.body).not_to include('designuser@test.com')
    end

    it 'returns only users with the selected organizational role' do
      create_user(organizational_roles: [design_team], email: 'onlydesign@test.com')
      create_user(organizational_roles: [ai_team], email: 'onlyai@test.com')
      create_user(email: 'norole@test.com')

      get '/users', params: { organizational_role_id: design_team.id }
      expect(response).to have_http_status(:success)
      expect(response.body).to include('onlydesign@test.com')
      expect(response.body).not_to include('onlyai@test.com')
      expect(response.body).not_to include('norole@test.com')
    end

    it 'handles users with no organizational roles when filtering' do
      create_user(organizational_roles: [ai_team], email: 'withrole@test.com')
      create_user(email: 'withoutrole@test.com')

      get '/users', params: { organizational_role_id: ai_team.id }
      expect(response).to have_http_status(:success)
      expect(response.body).to include('withrole@test.com')
      expect(response.body).not_to include('withoutrole@test.com')
    end

    it 'displays the filter dropdown with organizational roles' do
      ai_team # Force creation of ai_team
      design_team # Force creation of design_team

      get '/users'
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Filter by Organizational Role')
      expect(response.body).to include('AI Team')
      expect(response.body).to include('Design Team')
    end
  end
end
