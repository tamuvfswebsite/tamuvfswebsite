require 'rails_helper'

RSpec.describe ResumeDownload, type: :model do
  let(:user) do
    User.create!(google_uid: SecureRandom.uuid, email: 'user@example.com', first_name: 'Test', last_name: 'User')
  end
  let(:resume) do
    r = user.build_resume
    r.file.attach(io: File.open(Rails.root.join('spec/fixtures/test.pdf')), filename: 'test.pdf',
                  content_type: 'application/pdf')
    r.save!
    r
  end

  describe 'associations' do
    it 'belongs to a user' do
      download = ResumeDownload.new(user: user, resume: resume, downloaded_at: Time.current)
      expect(download.user).to eq(user)
    end

    it 'belongs to a resume' do
      download = ResumeDownload.new(user: user, resume: resume, downloaded_at: Time.current)
      expect(download.resume).to eq(resume)
    end
  end

  describe 'validations' do
    it 'is valid with all required attributes' do
      download = ResumeDownload.new(user: user, resume: resume, downloaded_at: Time.current)
      expect(download).to be_valid
    end

    it 'is invalid without downloaded_at' do
      download = ResumeDownload.new(user: user, resume: resume, downloaded_at: nil)
      expect(download).not_to be_valid
      expect(download.errors[:downloaded_at]).to be_present
    end

    it 'is invalid without user_id' do
      download = ResumeDownload.new(user: nil, resume: resume, downloaded_at: Time.current)
      expect(download).not_to be_valid
      expect(download.errors[:user_id]).to be_present
    end

    it 'is invalid without resume_id' do
      download = ResumeDownload.new(user: user, resume: nil, downloaded_at: Time.current)
      expect(download).not_to be_valid
      expect(download.errors[:resume_id]).to be_present
    end
  end

  describe 'scopes' do
    let(:sponsor_user) do
      User.create!(google_uid: 'sponsor123', email: 'sponsor@test.com', role: 'sponsor',
                   first_name: 'Sponsor', last_name: 'User')
    end
    let(:regular_user) do
      User.create!(google_uid: 'user123', email: 'regularuser@test.com', role: 'user',
                   first_name: 'Regular', last_name: 'User')
    end

    before do
      ResumeDownload.create!(user: sponsor_user, resume: resume, downloaded_at: Time.current)
      ResumeDownload.create!(user: regular_user, resume: resume, downloaded_at: Time.current)
    end

    describe '.by_sponsors' do
      it 'returns only downloads by sponsor users' do
        sponsor_downloads = ResumeDownload.by_sponsors
        expect(sponsor_downloads.count).to eq(1)
        expect(sponsor_downloads.first.user).to eq(sponsor_user)
      end
    end
  end

  describe '.sponsor_statistics' do
    let(:sponsor1) do
      User.create!(google_uid: 'sponsor1', email: 'sponsor1@test.com', role: 'sponsor',
                   first_name: 'John', last_name: 'Doe')
    end
    let(:sponsor2) do
      User.create!(google_uid: 'sponsor2', email: 'sponsor2@test.com', role: 'sponsor',
                   first_name: 'Jane', last_name: 'Smith')
    end

    before do
      # Sponsor 1 downloads 3 times
      3.times { ResumeDownload.create!(user: sponsor1, resume: resume, downloaded_at: Time.current) }
      # Sponsor 2 downloads 1 time
      ResumeDownload.create!(user: sponsor2, resume: resume, downloaded_at: Time.current)
    end

    it 'returns download statistics for sponsors ordered by download count' do
      stats = ResumeDownload.sponsor_statistics
      expect(stats.length).to eq(2)
      expect(stats.first.download_count).to eq(3)
      expect(stats.first.first_name).to eq('John')
      expect(stats.last.download_count).to eq(1)
      expect(stats.last.first_name).to eq('Jane')
    end

    it 'includes sponsor user details' do
      stats = ResumeDownload.sponsor_statistics
      first_stat = stats.first
      expect(first_stat.first_name).to eq('John')
      expect(first_stat.last_name).to eq('Doe')
      expect(first_stat.email).to eq('sponsor1@test.com')
    end
  end
end
