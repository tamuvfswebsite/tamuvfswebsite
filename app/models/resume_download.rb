class ResumeDownload < ApplicationRecord
  belongs_to :user
  belongs_to :resume

  validates :downloaded_at, presence: true
  validates :user_id, presence: true
  validates :resume_id, presence: true

  # Scope to get downloads by sponsor users only
  scope :by_sponsors, lambda {
    joins(:user).where(users: { role: 'sponsor' })
  }

  # Scope to get downloads within a date range
  scope :between_dates, ->(start_date, end_date) { where(downloaded_at: start_date..end_date) }

  # Class method to get sponsor download statistics
  def self.sponsor_statistics
    by_sponsors
      .joins(:user)
      .group('users.id', 'users.first_name', 'users.last_name', 'users.email')
      .select(
        'users.id as user_id',
        'users.first_name',
        'users.last_name',
        'users.email',
        'COUNT(resume_downloads.id) as download_count'
      )
      .order('download_count DESC, users.last_name ASC, users.first_name ASC')
  end
end
