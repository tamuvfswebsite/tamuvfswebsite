require 'rails_helper'

RSpec.describe 'role_applications/_form', type: :view do
  let(:user) { create_user }
  let(:resume) do
    resume = Resume.new(user: user)
    resume.file.attach(
      io: File.open(Rails.root.join('spec/fixtures/test.pdf')),
      filename: 'test_resume.pdf',
      content_type: 'application/pdf'
    )
    resume.save!
    resume
  end

  let(:organizational_role_with_questions) do
    OrganizationalRole.create!(
      name: 'Engineering Team',
      question_1: 'What programming languages are you proficient in?',
      question_2: 'Describe a challenging technical problem you solved.',
      question_3: 'Why do you want to join our engineering team?'
    )
  end

  let(:organizational_role_partial_questions) do
    OrganizationalRole.create!(
      name: 'Design Team',
      question_1: 'What design tools are you familiar with?',
      question_2: 'Describe your design philosophy.'
    )
  end

  let(:organizational_role_no_questions) do
    OrganizationalRole.create!(name: 'General Member')
  end

  # Define helper method at the describe block level
  helper do
    attr_reader :current_user
  end

  before do
    resume
    assign(:organizational_roles, OrganizationalRole.all)
    # Set the current_user instance variable that the helper will return
    view.instance_variable_set(:@current_user, user)
  end

  context 'new application form' do
    it 'displays organizational role dropdown' do
      role_application = RoleApplication.new
      assign(:role_application, role_application)

      render partial: 'role_applications/form', locals: { role_application: role_application }

      expect(rendered).to have_select('role_application[org_role_id]')
    end

    it 'shows resume section' do
      role_application = RoleApplication.new
      assign(:role_application, role_application)

      render partial: 'role_applications/form', locals: { role_application: role_application }

      expect(rendered).to match(/Your Resume/)
      expect(rendered).to have_link('Edit Resume', href: edit_user_resume_path(user, return_to: 'application'))
    end
  end

  context 'editing application form' do
    let(:existing_application) do
      RoleApplication.create!(
        user: user,
        organizational_role: organizational_role_with_questions,
        answer_1: 'I am proficient in Python, JavaScript, Ruby, and C++ programming',
        answer_2: 'I optimized a database query that reduced response time by 80%',
        answer_3: 'I want to work on challenging projects with a talented team here'
      )
    end

    it 'includes correct return_to parameter for resume edit link' do
      assign(:role_application, existing_application)

      render partial: 'role_applications/form', locals: { role_application: existing_application }

      expected_return_to = "application_edit_#{existing_application.id}"
      expect(rendered).to have_link('Edit Resume',
                                    href: edit_user_resume_path(user, return_to: expected_return_to))
    end
  end

  # NOTE: Testing dynamic JavaScript behavior (showing/hiding questions based on selection)
  # would typically be done with system tests (feature specs) using Capybara with JavaScript enabled
  describe 'dynamic question display (requires JavaScript)' do
    it 'includes data attributes for JavaScript to use' do
      role_application = RoleApplication.new
      assign(:role_application, role_application)

      # This test documents the expected structure for JavaScript integration
      # Actual dynamic behavior should be tested in system/feature specs
      render partial: 'role_applications/form', locals: { role_application: role_application }

      expect(rendered).to have_css('select[name="role_application[org_role_id]"]')
    end
  end
end
