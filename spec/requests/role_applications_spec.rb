require 'rails_helper'

RSpec.describe '/role_applications', type: :request do
  let(:user) { User.create!(email: 'test@example.com', first_name: 'Test', last_name: 'User', google_uid: '123') }
  let(:organizational_role) { OrganizationalRole.create!(name: 'Test Role') }

  # Create resume for the user
  let!(:resume) do
    resume = Resume.new(user: user, gpa: 3.5, graduation_date: 2025, major: 'Computer Science',
                        organizational_role: 'Student')
    resume.file.attach(io: File.open(Rails.root.join('spec/fixtures/test.pdf')), filename: 'test.pdf',
                       content_type: 'application/pdf')
    resume.save!
    resume
  end

  let(:valid_attributes) do
    {
      org_role_id: organizational_role.id,
      essay: 'This is a valid essay that is at least fifty characters long for validation purposes.'
    }
  end

  let(:invalid_attributes) do
    {
      org_role_id: nil,
      essay: 'Too short'
    }
  end

  # Helper to sign in user
  def sign_in_user
    # Simulate the session-based authentication
    allow_any_instance_of(RoleApplicationsController).to receive(:current_user).and_return(user)
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      sign_in_user
      get new_role_application_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      sign_in_user
      role_application = user.create_role_application!(valid_attributes)
      get role_application_url(role_application)
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'renders a successful response' do
      sign_in_user
      role_application = user.create_role_application!(valid_attributes)
      get edit_role_application_url(role_application)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new RoleApplication' do
        sign_in_user
        expect do
          post role_applications_url, params: { role_application: valid_attributes }
        end.to change(RoleApplication, :count).by(1)
      end

      it 'redirects to the created role_application' do
        sign_in_user
        post role_applications_url, params: { role_application: valid_attributes }
        expect(response).to redirect_to(role_application_url(RoleApplication.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new RoleApplication' do
        sign_in_user
        expect do
          post role_applications_url, params: { role_application: invalid_attributes }
        end.to change(RoleApplication, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        sign_in_user
        post role_applications_url, params: { role_application: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PATCH /update' do
    let(:new_attributes) do
      {
        essay: 'This is an updated essay that is also at least fifty characters long for validation.'
      }
    end

    context 'with valid parameters' do
      it 'updates the requested role_application' do
        sign_in_user
        role_application = user.create_role_application!(valid_attributes)
        patch role_application_url(role_application), params: { role_application: new_attributes }
        role_application.reload
        expect(role_application.essay).to eq(new_attributes[:essay])
      end

      it 'redirects to the role_application' do
        sign_in_user
        role_application = user.create_role_application!(valid_attributes)
        patch role_application_url(role_application), params: { role_application: new_attributes }
        expect(response).to redirect_to(role_application_url(role_application))
      end
    end

    context 'with invalid parameters' do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        sign_in_user
        role_application = user.create_role_application!(valid_attributes)
        patch role_application_url(role_application), params: { role_application: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'authorization' do
    let(:other_user) do
      User.create!(email: 'other@example.com', first_name: 'Other', last_name: 'User', google_uid: '456')
    end
    let(:admin_user) do
      User.create!(email: 'admin@example.com', first_name: 'Admin', last_name: 'User', google_uid: '999', role: 'admin')
    end

    it 'allows admins to view any role application' do
      role_application = user.create_role_application!(valid_attributes)
      admin = Admin.create!(email: admin_user.email, uid: admin_user.google_uid,
                            full_name: "#{admin_user.first_name} #{admin_user.last_name}")

      allow_any_instance_of(RoleApplicationsController).to receive(:admin_signed_in?).and_return(true)
      allow_any_instance_of(RoleApplicationsController).to receive(:current_admin).and_return(admin)
      allow_any_instance_of(RoleApplicationsController).to receive(:current_user).and_return(admin_user)

      get role_application_url(role_application)
      expect(response).to be_successful
    end

    it 'prevents viewing another users role application' do
      role_application = user.create_role_application!(valid_attributes)
      allow_any_instance_of(RoleApplicationsController).to receive(:current_user).and_return(other_user)

      get role_application_url(role_application)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include('You can only view your own application')
    end

    it 'prevents editing another users role application' do
      role_application = user.create_role_application!(valid_attributes)
      allow_any_instance_of(RoleApplicationsController).to receive(:current_user).and_return(other_user)

      get edit_role_application_url(role_application)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include('You can only view your own application')
    end

    it 'prevents updating another users role application' do
      role_application = user.create_role_application!(valid_attributes)
      allow_any_instance_of(RoleApplicationsController).to receive(:current_user).and_return(other_user)

      patch role_application_url(role_application), params: { role_application: { essay: 'Hacked!' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include('You can only view your own application')
      role_application.reload
      expect(role_application.essay).not_to eq('Hacked!')
    end

    it 'redirects to sign in when not authenticated' do
      allow_any_instance_of(RoleApplicationsController).to receive(:current_user).and_return(nil)

      get new_role_application_url
      expect(response).to redirect_to(admin_google_oauth2_omniauth_authorize_path)
      expect(flash[:alert]).to include('Please sign in')
    end

    it 'redirects when user has no resume' do
      user_no_resume = User.create!(email: 'noresume@example.com', first_name: 'No', last_name: 'Resume',
                                    google_uid: '789')
      allow_any_instance_of(RoleApplicationsController).to receive(:current_user).and_return(user_no_resume)

      get new_role_application_url
      expect(response).to redirect_to(new_user_resume_path(user_no_resume, return_to: 'application'))
      expect(flash[:alert]).to include('Please upload your resume before applying')
    end

    it 'redirects when user already has a role application' do
      user.create_role_application!(valid_attributes)
      sign_in_user

      get new_role_application_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include('You have already submitted an application')
    end
  end

  describe 'JSON format' do
    it 'creates role application in JSON format' do
      sign_in_user

      post role_applications_url,
           params: { role_application: valid_attributes },
           as: :json
      expect(response).to have_http_status(:created)
      expect(response.content_type).to include('application/json')
      json = JSON.parse(response.body)
      expect(json['essay']).to eq(valid_attributes[:essay])
    end

    it 'returns error on invalid JSON create' do
      sign_in_user

      post role_applications_url,
           params: { role_application: invalid_attributes },
           as: :json
      expect(response).to have_http_status(:unprocessable_content)
      json = JSON.parse(response.body)
      expect(json).to have_key('essay')
    end

    it 'updates role application in JSON format' do
      sign_in_user
      role_application = user.create_role_application!(valid_attributes)
      new_essay = 'This is a newly updated essay with more than fifty characters for validation.'

      patch role_application_url(role_application),
            params: { role_application: { essay: new_essay } },
            as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['essay']).to eq(new_essay)
    end

    it 'returns error on invalid JSON update' do
      sign_in_user
      role_application = user.create_role_application!(valid_attributes)

      patch role_application_url(role_application),
            params: { role_application: invalid_attributes },
            as: :json
      expect(response).to have_http_status(:unprocessable_content)
      json = JSON.parse(response.body)
      expect(json).to have_key('essay')
    end
  end
end
