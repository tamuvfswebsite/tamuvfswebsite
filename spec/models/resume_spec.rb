require 'rails_helper'

RSpec.describe Resume, type: :model do
  let(:user) { User.create!(google_uid: SecureRandom.uuid, email: 'test@example.com') }

  def attach_fixture(resume)
    resume.file.attach(io: File.open(Rails.root.join('spec/fixtures/test.pdf')), filename: 'test.pdf',
                       content_type: 'application/pdf')
  end

  it 'is valid with a file and optional fields within bounds' do
    resume = user.build_resume(gpa: 3.5, graduation_date: Date.today.year, major: 'Computer Science',
                               organizational_role: 'Student')
    attach_fixture(resume)
    expect(resume).to be_valid
  end

  it 'is invalid without a file' do
    resume = user.build_resume
    expect(resume).not_to be_valid
    expect(resume.errors[:file]).to include("can't be blank")
  end

  it 'rejects non-pdf files' do
    resume = user.build_resume
    resume.file.attach(io: StringIO.new('hello'), filename: 'test.txt', content_type: 'text/plain')
    resume.validate
    expect(resume.errors[:file]).to include('must be a PDF')
  end

  it 'validates gpa bounds' do
    resume = user.build_resume(gpa: 5.0)
    attach_fixture(resume)
    expect(resume).not_to be_valid
    expect(resume.errors[:gpa]).to be_present

    resume.gpa = -1
    resume.validate
    expect(resume.errors[:gpa]).to be_present
  end

  it 'validates graduation_date bounds' do
    resume = user.build_resume(graduation_date: 1800)
    attach_fixture(resume)
    expect(resume).not_to be_valid
    expect(resume.errors[:graduation_date]).to be_present

    resume.graduation_date = Date.today.year + 100
    resume.validate
    expect(resume.errors[:graduation_date]).to be_present
  end

  it 'validates string length for major and organizational_role' do
    long_string = 'a' * 200
    resume = user.build_resume(major: long_string, organizational_role: long_string)
    attach_fixture(resume)
    expect(resume).not_to be_valid
    expect(resume.errors[:major]).to be_present
    expect(resume.errors[:organizational_role]).to be_present
  end

  it 'rejects files larger than 5MB' do
    resume = user.build_resume
    # Create a large file (simulating > 5MB)
    large_content = 'a' * (6 * 1024 * 1024) # 6MB
    resume.file.attach(
      io: StringIO.new(large_content),
      filename: 'large.pdf',
      content_type: 'application/pdf'
    )
    resume.validate
    expect(resume.errors[:file]).to include('size must be less than 5MB')
  end
end
