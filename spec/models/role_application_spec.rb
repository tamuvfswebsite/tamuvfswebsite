require 'rails_helper'

RSpec.describe RoleApplication, type: :model do
  let(:user) { create_user }
  let(:organizational_role) do
    OrganizationalRole.create!(
      name: 'AI Team',
      question_1: 'What interests you about AI?',
      question_2: 'Describe your relevant experience.',
      question_3: 'What can you contribute to our team?'
    )
  end
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
        answer_1: 'I am fascinated by machine learning and its applications',
        answer_2: 'I have worked on several ML projects in my coursework',
        answer_3: 'I can bring strong Python and data analysis skills to the team'
      )
      expect(application.user).to eq(user)
    end

    it 'belongs to an organizational role' do
      application = RoleApplication.new(
        user: user,
        organizational_role: organizational_role,
        answer_1: 'I am fascinated by machine learning and its applications',
        answer_2: 'I have worked on several ML projects in my coursework',
        answer_3: 'I can bring strong Python and data analysis skills to the team'
      )
      expect(application.organizational_role).to eq(organizational_role)
    end
  end

  describe 'validations' do
    context 'answer validations' do
      it 'requires answer_1 when question_1 is present' do
        resume
        application = RoleApplication.new(
          user: user,
          organizational_role: organizational_role,
          answer_1: nil,
          answer_2: 'I have worked on several ML projects in my coursework',
          answer_3: 'I can bring strong Python and data analysis skills to the team'
        )
        expect(application).not_to be_valid
        expect(application.errors[:answer_1]).to include("can't be blank")
      end

      it 'requires answer_2 when question_2 is present' do
        resume
        application = RoleApplication.new(
          user: user,
          organizational_role: organizational_role,
          answer_1: 'I am fascinated by machine learning and its applications',
          answer_2: nil,
          answer_3: 'I can bring strong Python and data analysis skills to the team'
        )
        expect(application).not_to be_valid
        expect(application.errors[:answer_2]).to include("can't be blank")
      end

      it 'requires answer_3 when question_3 is present' do
        resume
        application = RoleApplication.new(
          user: user,
          organizational_role: organizational_role,
          answer_1: 'I am fascinated by machine learning and its applications',
          answer_2: 'I have worked on several ML projects in my coursework',
          answer_3: nil
        )
        expect(application).not_to be_valid
        expect(application.errors[:answer_3]).to include("can't be blank")
      end

      it 'requires answer_1 to be at least 50 characters when present' do
        resume
        application = RoleApplication.new(
          user: user,
          organizational_role: organizational_role,
          answer_1: 'Short',
          answer_2: 'I have worked on several ML projects in my coursework and gained experience',
          answer_3: 'I can bring strong Python and data analysis skills to the team'
        )
        expect(application).not_to be_valid
        expect(application.errors[:answer_1]).to include('is too short (minimum is 50 characters)')
      end

      it 'requires answer_2 to be at least 50 characters when present' do
        resume
        application = RoleApplication.new(
          user: user,
          organizational_role: organizational_role,
          answer_1: 'I am fascinated by machine learning and its applications in various fields',
          answer_2: 'Short',
          answer_3: 'I can bring strong Python and data analysis skills to the team'
        )
        expect(application).not_to be_valid
        expect(application.errors[:answer_2]).to include('is too short (minimum is 50 characters)')
      end

      it 'requires answer_3 to be at least 50 characters when present' do
        resume
        application = RoleApplication.new(
          user: user,
          organizational_role: organizational_role,
          answer_1: 'I am fascinated by machine learning and its applications in various fields',
          answer_2: 'I have worked on several ML projects in my coursework and gained experience',
          answer_3: 'Short'
        )
        expect(application).not_to be_valid
        expect(application.errors[:answer_3]).to include('is too short (minimum is 50 characters)')
      end

      it 'allows answers that meet minimum length requirements' do
        resume
        application = RoleApplication.new(
          user: user,
          organizational_role: organizational_role,
          answer_1: 'I am fascinated by machine learning and its applications in various fields',
          answer_2: 'I have worked on several ML projects in my coursework and gained experience',
          answer_3: 'I can bring strong Python and data analysis skills to the team'
        )
        expect(application).to be_valid
      end

      it 'does not require answers when organizational role has no questions' do
        resume
        role_without_questions = OrganizationalRole.create!(name: 'Simple Role')
        application = RoleApplication.new(
          user: user,
          organizational_role: role_without_questions,
          answer_1: nil,
          answer_2: nil,
          answer_3: nil
        )
        expect(application).to be_valid
      end

      it 'allows partial answers when organizational role has partial questions' do
        resume
        role_with_one_question = OrganizationalRole.create!(
          name: 'Design Team',
          question_1: 'What design tools are you familiar with?'
        )
        application = RoleApplication.new(
          user: user,
          organizational_role: role_with_one_question,
          answer_1: 'I am proficient with Figma, Adobe XD, and Sketch design tools',
          answer_2: nil,
          answer_3: nil
        )
        expect(application).to be_valid
      end
    end

    context 'user uniqueness' do
      it 'requires user_id to be unique' do
        resume # Create resume for user
        RoleApplication.create!(
          user: user,
          organizational_role: organizational_role,
          answer_1: 'I am fascinated by machine learning and its applications in various fields',
          answer_2: 'I have worked on several ML projects in my coursework and gained experience',
          answer_3: 'I can bring strong Python and data analysis skills to the team'
        )

        duplicate = RoleApplication.new(
          user: user,
          organizational_role: organizational_role,
          answer_1: 'Different answer with more than fifty characters to meet requirements',
          answer_2: 'Another different answer with more than fifty characters here too',
          answer_3: 'Yet another answer with more than fifty characters in this field'
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
          answer_1: 'I am fascinated by machine learning and its applications in various fields',
          answer_2: 'I have worked on several ML projects in my coursework and gained experience',
          answer_3: 'I can bring strong Python and data analysis skills to the team'
        )

        application2 = RoleApplication.new(
          user: user2,
          organizational_role: organizational_role,
          answer_1: 'I am passionate about artificial intelligence and want to learn more',
          answer_2: 'I have experience with Python, TensorFlow, and various AI frameworks',
          answer_3: 'I can contribute my enthusiasm and dedication to learning new things'
        )

        expect(application2).to be_valid
      end
    end

    context 'resume requirement' do
      it 'requires user to have an attached resume' do
        application = RoleApplication.new(
          user: user,
          organizational_role: organizational_role,
          answer_1: 'I am fascinated by machine learning and its applications in various fields',
          answer_2: 'I have worked on several ML projects in my coursework and gained experience',
          answer_3: 'I can bring strong Python and data analysis skills to the team'
        )

        expect(application).not_to be_valid
        expect(application.errors[:base]).to include('You must upload a resume before submitting an application')
      end

      it 'is valid when user has an attached resume' do
        resume # Create resume with attached file

        application = RoleApplication.new(
          user: user,
          organizational_role: organizational_role,
          answer_1: 'I am fascinated by machine learning and its applications in various fields',
          answer_2: 'I have worked on several ML projects in my coursework and gained experience',
          answer_3: 'I can bring strong Python and data analysis skills to the team'
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
        answer_1: 'I am passionate about joining this team and bringing my skills',
        answer_2: 'I have experience with relevant technologies and collaborative work',
        answer_3: 'I can contribute to the mission through dedication and hard work'
      )

      expect(application).to be_persisted
      expect(application.user).to eq(user)
      expect(application.organizational_role).to eq(organizational_role)
      expect(application.answer_1).to eq('I am passionate about joining this team and bringing my skills')
      expect(application.answer_2).to eq('I have experience with relevant technologies and collaborative work')
      expect(application.answer_3).to eq('I can contribute to the mission through dedication and hard work')
    end

    it 'successfully creates with partial answers when role has partial questions' do
      resume
      role_with_two_questions = OrganizationalRole.create!(
        name: 'Marketing Team',
        question_1: 'What marketing experience do you have?',
        question_2: 'Describe a successful campaign.'
      )

      application = RoleApplication.create!(
        user: user,
        organizational_role: role_with_two_questions,
        answer_1: 'I have three years of digital marketing experience in social media',
        answer_2: 'I led a campaign that increased engagement by 300% over six months'
      )

      expect(application).to be_persisted
      expect(application.answer_1).to be_present
      expect(application.answer_2).to be_present
      expect(application.answer_3).to be_nil
    end
  end
end
