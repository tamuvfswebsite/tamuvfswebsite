require 'rails_helper'

RSpec.describe AdminPanel::RoleApplicationsController, type: :request do
  let(:admin_user) { create_user(role: 'admin') }
  # Create a role with no questions to simplify testing
  let(:org_role) { OrganizationalRole.create!(name: 'Test Role', description: 'Test Description') }
  let(:user1) do
    user = create_user(uid: 'user1', email: 'user1@test.com')
    attach_resume_to_user(user)
    user
  end
  let(:user2) do
    user = create_user(uid: 'user2', email: 'user2@test.com')
    attach_resume_to_user(user)
    user
  end

  # Helper method to attach a dummy resume to a user
  def attach_resume_to_user(user)
    resume = user.resume || user.build_resume
    resume.file.attach(io: StringIO.new('dummy resume'), filename: 'resume.pdf', content_type: 'application/pdf')
    resume.save!
  end

  before do
    sign_in_as_admin(admin_user)
  end

  describe 'GET /admin_panel/role_applications' do
    it 'displays all role applications' do
      user1.create_role_application!(org_role_id: org_role.id, status: 'not_reviewed')
      user2.create_role_application!(org_role_id: org_role.id, status: 'accepted')

      get admin_panel_role_applications_path
      expect(response).to be_successful
      expect(response.body).to include('user1@test.com')
      expect(response.body).to include('user2@test.com')
    end

    it 'includes user and organizational role information' do
      user1.create_role_application!(org_role_id: org_role.id)

      get admin_panel_role_applications_path
      expect(response).to be_successful
      expect(response.body).to include('Test Role')
      expect(response.body).to include(user1.email)
    end

    it 'orders applications by created_at descending (newest first)' do
      # Create applications with specific times
      app1 = user1.create_role_application!(org_role_id: org_role.id)
      app1.update_column(:created_at, 2.days.ago)

      user3 = create_user(uid: 'user3', email: 'user3@test.com')
      attach_resume_to_user(user3)
      app2 = user3.create_role_application!(org_role_id: org_role.id)
      app2.update_column(:created_at, 1.day.ago)

      get admin_panel_role_applications_path
      expect(response).to be_successful

      # Newer application should appear first
      new_position = response.body.index('user3@test.com')
      old_position = response.body.index('user1@test.com')
      expect(new_position).to be < old_position
    end

    it 'filters by not_reviewed status when status param provided' do
      user1.create_role_application!(org_role_id: org_role.id,
                                     status: 'not_reviewed')
      user2.create_role_application!(org_role_id: org_role.id,
                                     status: 'accepted')

      get admin_panel_role_applications_path, params: { status: { not_reviewed: '1' } }
      expect(response).to be_successful
      expect(response.body).to include('user1@test.com')
      expect(response.body).not_to include('user2@test.com')
    end

    it 'filters by multiple statuses' do
      user1.create_role_application!(org_role_id: org_role.id,
                                     status: 'not_reviewed')

      user3 = create_user(uid: 'user3', email: 'user3@test.com')
      attach_resume_to_user(user3)
      user3.create_role_application!(org_role_id: org_role.id,
                                     status: 'accepted')

      user2.create_role_application!(org_role_id: org_role.id,
                                     status: 'rejected')

      get admin_panel_role_applications_path, params: { status: { not_reviewed: '1', accepted: '1' } }
      expect(response).to be_successful
      expect(response.body).to include('user1@test.com')
      expect(response.body).to include('user3@test.com')
      expect(response.body).not_to include('user2@test.com')
    end

    it 'shows all applications when no status filter provided' do
      user1.create_role_application!(org_role_id: org_role.id, status: 'not_reviewed')
      user2.create_role_application!(org_role_id: org_role.id, status: 'accepted')

      get admin_panel_role_applications_path
      expect(response).to be_successful
      expect(response.body).to include('user1@test.com')
      expect(response.body).to include('user2@test.com')
    end

    it 'ignores invalid status filters' do
      user1.create_role_application!(org_role_id: org_role.id)

      get admin_panel_role_applications_path, params: { status: { invalid: '1' } }
      expect(response).to be_successful
    end
  end

  describe 'GET /admin_panel/role_applications/:id' do
    let(:application) { user1.create_role_application!(org_role_id: org_role.id) }

    it 'displays full application details' do
      get admin_panel_role_application_path(application)
      expect(response).to be_successful
      expect(response.body).to include(user1.email)
      expect(response.body).to include('Test Role')
    end

    it 'returns 404 when application does not exist' do
      get admin_panel_role_application_path(id: 99_999)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /admin_panel/role_applications/:id/update_status' do
    let(:application) do
      user1.create_role_application!(org_role_id: org_role.id, status: 'not_reviewed')
    end

    it 'updates application status successfully' do
      patch update_status_admin_panel_role_application_path(application),
            params: { role_application: { status: 'accepted' } }

      expect(response).to redirect_to(admin_panel_role_applications_path)
      expect(flash[:notice]).to eq('Status updated successfully.')
      expect(application.reload.status).to eq('accepted')
    end

    it 'can update to rejected status' do
      patch update_status_admin_panel_role_application_path(application),
            params: { role_application: { status: 'rejected' } }

      expect(application.reload.status).to eq('rejected')
      expect(flash[:notice]).to eq('Status updated successfully.')
    end

    it 'shows alert on update failure' do
      # Force validation failure by using invalid status
      allow_any_instance_of(RoleApplication).to receive(:update).and_return(false)

      patch update_status_admin_panel_role_application_path(application),
            params: { role_application: { status: 'invalid_status' } }

      expect(response).to redirect_to(admin_panel_role_applications_path)
      expect(flash[:alert]).to eq('Failed to update status.')
    end

    it 'returns 404 when application does not exist' do
      patch update_status_admin_panel_role_application_path(id: 99_999),
            params: { role_application: { status: 'accepted' } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /admin_panel/role_applications/:id' do
    let(:application) { user1.create_role_application!(org_role_id: org_role.id) }

    it 'deletes the application successfully' do
      # Force creation of the application before the expect block
      application_id = application.id

      expect do
        delete admin_panel_role_application_path(application_id)
      end.to change(RoleApplication, :count).by(-1)

      expect(response).to redirect_to(admin_panel_role_applications_path)
      expect(flash[:notice]).to eq('Application was successfully deleted.')
    end

    it 'returns 404 when application does not exist' do
      delete admin_panel_role_application_path(id: 99_999)
      expect(response).to have_http_status(:not_found)
    end
  end
end
