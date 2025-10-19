require 'rails_helper'

RSpec.describe RoleApplication, type: :model do
  let(:user) { create_user }
  let(:organizational_role) { OrganizationalRole.create!(name: 'AI Team') }
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

  describe 'associations' do
    it 'belongs to a user' do
      application = RoleApplication.new(
        user: user,
        organizational_role: organizational_role,
        essay: 'This is a test essay that is long enough to pass validation requirements for the application.'
      )
      expect(application.user).to eq(user)
    end

    it 'belongs to an organizational role' do
      application = RoleApplication.new(
        user: user,
        organizational_role: organizational_role,
        essay: 'This is a test essay that is long enough to pass validation requirements for the application.'
      )
      expect(application.organizational_role).to eq(organizational_role)
    end
  end

  describe 'validations' do
    context 'essay validation' do
      it 'requires an essay to be present' do
        application = RoleApplication.new(
          user: user,
          organizational_role: organizational_role,
          essay: nil
        )
        expect(application).not_to be_valid
        expect(application.errors[:essay]).to include("can't be blank")
      end

      it 'requires essay to be at least 50 characters' do
        application = RoleApplication.new(
          user: user,
          organizational_role: organizational_role,
          essay: 'Short essay'
        )
        expect(application).not_to be_valid
        expect(application.errors[:essay]).to include('is too short (minimum is 50 characters)')
      end

      it 'accepts essay with 50 or more characters' do
        application = RoleApplication.new(
          user: user,
          organizational_role: organizational_role,
          essay: 'This is a sufficiently long essay that meets the minimum character requirement.'
        )
        expect(application.essay.length).to be >= 50
      end
    end

    context 'user uniqueness' do
      it 'requires user_id to be unique' do
        resume # Create resume for user
        RoleApplication.create!(
          user: user,
          organizational_role: organizational_role,
          essay: 'This is my first application essay with enough characters to pass validation.'
        )

        duplicate = RoleApplication.new(
          user: user,
          organizational_role: organizational_role,
          essay: 'This is my second application essay with enough characters to pass validation.'
        )

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:user_id]).to include('has already submitted an application')
      end

      it 'allows different users to submit applications' do
        user2 = create_user
        resume2 = Resume.new(user: user2)
        resume2.file.attach(
          io: File.open(Rails.root.join('spec/fixtures/test.pdf')),
          filename: 'test_resume2.pdf',
          content_type: 'application/pdf'
        )
        resume2.save!

        resume # Create resume for first user

        RoleApplication.create!(
          user: user,
          organizational_role: organizational_role,
          essay: 'This is the first users application essay with enough characters.'
        )

        application2 = RoleApplication.new(
          user: user2,
          organizational_role: organizational_role,
          essay: 'This is the second users application essay with enough characters.'
        )

        expect(application2).to be_valid
      end
    end

    context 'resume requirement' do
      it 'requires user to have an attached resume' do
        application = RoleApplication.new(
          user: user,
          organizational_role: organizational_role,
          essay: 'This is a test essay that is long enough to pass validation requirements.'
        )

        expect(application).not_to be_valid
        expect(application.errors[:base]).to include('You must upload a resume before submitting an application')
      end

      it 'is valid when user has an attached resume' do
        resume # Create resume with attached file

        application = RoleApplication.new(
          user: user,
          organizational_role: organizational_role,
          essay: 'This is a test essay that is long enough to pass validation requirements.'
        )

        expect(application).to be_valid
      end
    end
  end

  describe 'creating a valid application' do
    it 'successfully creates with all valid attributes' do
      resume # Create resume for user

      application = RoleApplication.create!(
        user: user,
        organizational_role: organizational_role,
        essay: 'I am passionate about joining this team and bringing my skills to contribute to the mission.'
      )

      expect(application).to be_persisted
      expect(application.user).to eq(user)
      expect(application.organizational_role).to eq(organizational_role)
      expect(application.essay).to eq(
        'I am passionate about joining this team and bringing my skills to contribute to the mission.'
      )
    end
  end
end
