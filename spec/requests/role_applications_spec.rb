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
        expect(response).to have_http_status(:unprocessable_entity)
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
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
