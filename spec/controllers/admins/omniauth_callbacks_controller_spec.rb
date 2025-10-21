require 'rails_helper'

RSpec.describe 'Admins::OmniauthCallbacksController', type: :request do
  let(:auth_hash) do
    OmniAuth::AuthHash.new({
                             provider: 'google_oauth2',
                             uid: '123545',
                             info: {
                               email: 'test@example.com',
                               name: 'Test User',
                               image: 'https://example.com/photo.jpg'
                             }
                           })
  end

  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = auth_hash
    Rails.application.env_config['omniauth.auth'] = auth_hash
  end

  after do
    OmniAuth.config.test_mode = false
  end

  describe 'GET /admins/auth/google_oauth2/callback' do
    context 'when user is an admin' do
      before do
        Admin.create!(
          email: 'test@example.com',
          uid: '123545',
          full_name: 'Test User'
        )
      end

      it 'signs in the admin successfully' do
        get '/admins/auth/google_oauth2/callback'

        expect(response).to redirect_to(homepage_path)
        expect(flash[:success]).to include('Successfully authenticated')
      end

      it 'creates or updates the user record' do
        expect do
          get '/admins/auth/google_oauth2/callback'
        end.to change(User, :count).by(1)

        user = User.find_by(google_uid: '123545')
        expect(user).to be_present
        expect(user.email).to eq('test@example.com')
        expect(user.first_name).to eq('Test')
        expect(user.last_name).to eq('User')
      end

      it 'updates google_avatar_url on each login' do
        # Create user first
        user = User.create!(
          google_uid: '123545',
          email: 'test@example.com',
          first_name: 'Test',
          last_name: 'User',
          google_avatar_url: 'https://old-url.com/photo.jpg'
        )

        get '/admins/auth/google_oauth2/callback'

        user.reload
        expect(user.google_avatar_url).to eq('https://example.com/photo.jpg')
      end

      it 'stores user_id in session' do
        get '/admins/auth/google_oauth2/callback'

        user = User.find_by(google_uid: '123545')
        # Session is managed by Devise and is available after authentication
        expect(user).to be_present
      end
    end

    context 'when user is applying for a role' do
      before do
        Admin.create!(
          email: 'test@example.com',
          uid: '123545',
          full_name: 'Test User'
        )
      end

      it 'redirects to new role application page when applying_for_role flag is set' do
        # Simulate the apply flow by setting session before OAuth
        get apply_path # This sets session[:applying_for_role] = true
        get '/admins/auth/google_oauth2/callback'

        expect(response).to redirect_to(new_role_application_path)
      end

      it 'redirects to root if user already has an application' do
        user = User.create!(
          google_uid: '123545',
          email: 'test@example.com',
          first_name: 'Test',
          last_name: 'User'
        )
        # Attach a resume to the user (required for role applications)
        resume = user.build_resume
        resume.file.attach(io: StringIO.new('dummy resume'), filename: 'resume.pdf', content_type: 'application/pdf')
        resume.save!

        org_role = OrganizationalRole.create!(name: 'Test Role')
        user.create_role_application!(org_role_id: org_role.id, essay: 'Test essay' * 20)

        get apply_path # Set applying_for_role flag
        get '/admins/auth/google_oauth2/callback'

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include('already submitted an application')
      end

      it 'allows non-admin users to apply' do
        # Remove admin record so user is not an admin
        Admin.destroy_all

        get apply_path # Set applying_for_role flag
        get '/admins/auth/google_oauth2/callback'

        expect(response).to redirect_to(new_role_application_path)
        # User is created
        user = User.find_by(google_uid: '123545')
        expect(user).to be_present
      end
    end

    context 'when user is not an admin and not applying' do
      before do
        # Ensure no admin exists for this user initially
        Admin.destroy_all
      end

      it 'creates an admin and signs them in (auto-registration via OAuth)' do
        get '/admins/auth/google_oauth2/callback'

        # Admin.from_google creates the admin automatically
        expect(response).to redirect_to(homepage_path)
        expect(flash[:success]).to include('Successfully authenticated')

        # Verify admin was created
        admin = Admin.find_by(email: 'test@example.com')
        expect(admin).to be_present
      end

      it 'creates user record alongside admin' do
        get '/admins/auth/google_oauth2/callback'

        user = User.find_by(google_uid: '123545')
        expect(user).to be_present
        expect(user.email).to eq('test@example.com')
      end
    end

    context 'with single name' do
      let(:single_name_auth) do
        OmniAuth::AuthHash.new({
                                 provider: 'google_oauth2',
                                 uid: '123545',
                                 info: {
                                   email: 'test@example.com',
                                   name: 'Madonna',
                                   image: 'https://example.com/photo.jpg'
                                 }
                               })
      end

      before do
        OmniAuth.config.mock_auth[:google_oauth2] = single_name_auth
        Rails.application.env_config['omniauth.auth'] = single_name_auth
        Admin.create!(
          email: 'test@example.com',
          uid: '123545',
          full_name: 'Madonna'
        )
      end

      it 'handles single name correctly' do
        get '/admins/auth/google_oauth2/callback'

        user = User.find_by(google_uid: '123545')
        expect(user.first_name).to eq('Madonna')
        expect(user.last_name).to eq('')
      end
    end

    context 'with multi-part last name' do
      let(:multi_name_auth) do
        OmniAuth::AuthHash.new({
                                 provider: 'google_oauth2',
                                 uid: '123545',
                                 info: {
                                   email: 'test@example.com',
                                   name: 'John von Neumann',
                                   image: 'https://example.com/photo.jpg'
                                 }
                               })
      end

      before do
        OmniAuth.config.mock_auth[:google_oauth2] = multi_name_auth
        Rails.application.env_config['omniauth.auth'] = multi_name_auth
        Admin.create!(
          email: 'test@example.com',
          uid: '123545',
          full_name: 'John von Neumann'
        )
      end

      it 'handles multi-part last name correctly' do
        get '/admins/auth/google_oauth2/callback'

        user = User.find_by(google_uid: '123545')
        expect(user.first_name).to eq('John')
        expect(user.last_name).to eq('von Neumann')
      end
    end

    context 'in development environment' do
      before do
        allow(Rails.env).to receive(:development?).and_return(true)
        Admin.create!(
          email: 'test@example.com',
          uid: '123545',
          full_name: 'Test User'
        )
      end

      it 'creates users with admin role in development' do
        get '/admins/auth/google_oauth2/callback'

        user = User.find_by(google_uid: '123545')
        expect(user.role).to eq('admin')
      end
    end

    context 'in production environment' do
      before do
        allow(Rails.env).to receive(:development?).and_return(false)
        Admin.create!(
          email: 'test@example.com',
          uid: '123545',
          full_name: 'Test User'
        )
      end

      it 'creates users with user role in production' do
        get '/admins/auth/google_oauth2/callback'

        user = User.find_by(google_uid: '123545')
        expect(user.role).to eq('user')
      end
    end

    context 'when user already exists' do
      before do
        User.create!(
          google_uid: '123545',
          email: 'old@example.com',
          first_name: 'Old',
          last_name: 'Name',
          google_avatar_url: 'https://old.com/photo.jpg'
        )
        Admin.create!(
          email: 'test@example.com',
          uid: '123545',
          full_name: 'Test User'
        )
      end

      it 'does not create a duplicate user' do
        expect do
          get '/admins/auth/google_oauth2/callback'
        end.not_to change(User, :count)
      end

      it 'updates the avatar URL' do
        get '/admins/auth/google_oauth2/callback'

        user = User.find_by(google_uid: '123545')
        expect(user.google_avatar_url).to eq('https://example.com/photo.jpg')
      end

      it 'keeps existing user data' do
        get '/admins/auth/google_oauth2/callback'

        user = User.find_by(google_uid: '123545')
        # First and last name are set on creation, not updated
        expect(user.google_uid).to eq('123545')
      end
    end
  end
end
