require 'rails_helper'

RSpec.describe 'role_applications/new', type: :view do
  let(:user) { User.create!(email: 'test@example.com', first_name: 'Test', last_name: 'User', google_uid: '123') }
  let(:organizational_role) { OrganizationalRole.create!(name: 'Test Role') }

  let!(:resume) do
    resume = Resume.new(user: user, gpa: 3.5, graduation_date: 2025, major: 'Computer Science')
    resume.file.attach(io: File.open(Rails.root.join('spec/fixtures/test.pdf')), filename: 'test.pdf',
                       content_type: 'application/pdf')
    resume.save!
    resume
  end

  before(:each) do
    assign(:role_application, RoleApplication.new)
    assign(:organizational_roles, [organizational_role])
    # Stub the helper method that the view uses
    def view.current_user
      @current_user_stub
    end
    view.instance_variable_set(:@current_user_stub, user)
  end

  it 'renders new role_application form' do
    render

    assert_select 'form[action=?][method=?]', role_applications_path, 'post' do
      assert_select 'select[name=?]', 'role_application[org_role_id]'
      # With our dynamic form, answer fields only appear when a role is selected
      # Since role_application.organizational_role is nil for a new application, no answer fields appear initially
    end
  end
end
