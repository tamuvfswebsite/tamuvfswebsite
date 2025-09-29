class Resume < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  validates :file, presence: true
  validate :file_format

  private

  def file_format
    return unless file.attached?

    if !file.content_type.in?(%w[application/pdf])
      errors.add(:file, 'must be a PDF')
    end

    if file.byte_size > 5.megabytes
      errors.add(:file, 'size must be less than 5MB')
    end
  end
end
