class Resume < ApplicationRecord
  belongs_to :user
  has_one_attached :file
  has_many :resume_downloads, dependent: :destroy

  # Delegate organizational_role (primary) to user for convenience
  delegate :organizational_role, to: :user, allow_nil: true
  # Delegate organizational_roles (all) to user
  delegate :organizational_roles, to: :user

  validates :file, presence: true
  validates :gpa,
            numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 4.0 },
            allow_nil: true
  validates :graduation_date,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1900,
              less_than_or_equal_to: -> { Date.today.year + 8 }
            },
            allow_nil: true
  validates :major, length: { maximum: 100 }, allow_blank: true

  validate :file_format

  private

  def file_format
    return unless file.attached?

    errors.add(:file, 'must be a PDF') unless file.content_type == 'application/pdf'

    return unless file.byte_size > 5.megabytes

    errors.add(:file, 'size must be less than 5MB')
  end
end
