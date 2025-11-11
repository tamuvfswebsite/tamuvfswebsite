# app/models/design_update.rb
class DesignUpdate < ApplicationRecord
  has_one_attached :pdf_file

  validates :title, presence: true, length: { maximum: 200 }
  validates :update_date, presence: true
  validates :pdf_file, presence: true, on: :create

  validate :pdf_file_format

  scope :recent, -> { order(update_date: :desc, created_at: :desc) }

  private

  def pdf_file_format
    return unless pdf_file.attached?

    errors.add(:pdf_file, 'must be a PDF file') unless pdf_file.content_type == 'application/pdf'

    return unless pdf_file.byte_size > 10.megabytes

    errors.add(:pdf_file, 'must be less than 10MB')
  end
end
