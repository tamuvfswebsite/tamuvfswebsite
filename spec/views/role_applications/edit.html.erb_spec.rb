require 'rails_helper'

RSpec.describe 'role_applications/edit', type: :view do
  let(:user) { User.create!(email: 'test@example.com', first_name: 'Test', last_name: 'User', google_uid: '123') }
  let(:organizational_role) { OrganizationalRole.create!(name: 'Test Role') }

  let!(:resume) do
    resume = Resume.new(user: user, gpa: 3.5, graduation_date: 2025, major: 'Computer Science')
    resume.file.attach(io: File.open(Rails.root.join('spec/fixtures/test.pdf')), filename: 'test.pdf',
                       content_type: 'application/pdf')
    resume.save!
    resume
  end

  let(:role_application) do
    RoleApplication.create!(
      user: user,
      organizational_role: organizational_role
    )
  end

  before(:each) do
    assign(:role_application, role_application)
    assign(:organizational_roles, [organizational_role])
    # Stub the helper method that the view uses
    def view.current_user
      @current_user_stub
    end
    view.instance_variable_set(:@current_user_stub, user)
  end

  it 'renders the edit role_application form' do
    render

    assert_select 'form[action=?][method=?]', role_application_path(role_application), 'post' do
      assert_select 'select[name=?]', 'role_application[org_role_id]'
      # Since the organizational_role has no questions, no answer fields will be present
    end
  end
end
