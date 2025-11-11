require 'rails_helper'

RSpec.describe 'role_applications/index', type: :view do
  let(:user1) { User.create!(email: 'test1@example.com', first_name: 'Test1', last_name: 'User', google_uid: '123') }
  let(:user2) { User.create!(email: 'test2@example.com', first_name: 'Test2', last_name: 'User', google_uid: '456') }
  let(:organizational_role) { OrganizationalRole.create!(name: 'Test Role') }

  let!(:resume1) do
    resume = Resume.new(user: user1, gpa: 3.5, graduation_date: 2025, major: 'Computer Science')
    resume.file.attach(io: File.open(Rails.root.join('spec/fixtures/test.pdf')), filename: 'test.pdf',
                       content_type: 'application/pdf')
    resume.save!
    resume
  end

  let!(:resume2) do
    resume = Resume.new(user: user2, gpa: 3.8, graduation_date: 2026, major: 'Engineering')
    resume.file.attach(io: File.open(Rails.root.join('spec/fixtures/test.pdf')), filename: 'test.pdf',
                       content_type: 'application/pdf')
    resume.save!
    resume
  end

  before(:each) do
    assign(:role_applications, [
             RoleApplication.create!(
               user: user1,
               organizational_role: organizational_role
             ),
             RoleApplication.create!(
               user: user2,
               organizational_role: organizational_role
             )
           ])
  end

  it 'renders a list of role_applications' do
    render
    # Check for the table structure
    assert_select 'table.table'
    assert_select 'tbody>tr', count: 2
    # Check for organizational role names
    assert_select 'td', text: /Test Role/, count: 2
    # Check for application count
    assert_select 'p', text: /2 of 10 applications used/, count: 1
  end
end
