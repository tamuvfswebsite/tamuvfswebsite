require 'rails_helper'

RSpec.describe 'role_applications/show', type: :view do
  let(:user) { User.create!(email: 'test@example.com', first_name: 'Test', last_name: 'User', google_uid: '123') }
  let(:organizational_role) { OrganizationalRole.create!(name: 'Test Role') }

  let!(:resume) do
    resume = Resume.new(user: user, gpa: 3.5, graduation_date: 2025, major: 'Computer Science',
                        organizational_role: 'Student')
    resume.file.attach(io: File.open(Rails.root.join('spec/fixtures/test.pdf')), filename: 'test.pdf',
                       content_type: 'application/pdf')
    resume.save!
    resume
  end

  before(:each) do
    assign(:role_application, RoleApplication.create!(
                                user: user,
                                organizational_role: organizational_role,
                                essay: 'This is a test essay that is at least fifty characters long for validation.'
                              ))
    # Stub the helper method that the view uses
    def view.current_user
      @current_user_stub
    end
    view.instance_variable_set(:@current_user_stub, user)
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Test User/)
    expect(rendered).to match(/Test Role/)
    expect(rendered).to match(/This is a test essay/)
  end
end
