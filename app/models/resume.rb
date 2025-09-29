class Resume < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  validate :file_format

  private

  def file_format
    if file.attached? && !file.content_type.in?(%w(application/pdf))
      errors.add(:file, 'must be a PDF')
    elsif file.attached? && file.byte_size > 5.megabytes
      errors.add(:file, 'size must be less than 5MB')
    end
  end
  
end
