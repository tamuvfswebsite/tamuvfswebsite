class Sponsor < ApplicationRecord
  validates :company_name, presence: true, uniqueness: true
  has_many :sponsor_user_joins, dependent: :destroy
  has_many :users, through: :sponsor_user_joins
  has_many :logo_placements, class_name: 'AdminPanel::LogoPlacement', dependent: :destroy

  has_one_attached :logo
  validate :acceptable_logo

  # Check if this is the default sponsor
  def default_sponsor?
    company_name == 'Unassigned Sponsor'
  end

  # Get or create the default sponsor
  def self.default_sponsor
    find_or_create_by!(company_name: 'Unassigned Sponsor') do |s|
      s.tier = 'Bronze'
      s.contact_email = 'admin@example.com'
      s.website = 'https://example.com'
      s.company_description = 'Default sponsor for users not yet assigned to a company'
      s.resume_access = false
    end
  end

  # Override destroy to reassign users to default sponsor
  def destroy
    return false if default_sponsor?

    default = self.class.default_sponsor
    users.each do |user|
      user.sponsors.clear
      user.sponsors << default unless user.sponsors.include?(default)
    end
    super
  end

  def logo_url
    return nil unless logo.attached?

    Rails.application.routes.url_helpers.rails_blob_path(logo, only_path: true)
  end

  private

  def acceptable_logo
    return unless logo.attached?

    # Check file size (limit to 5MB)
    errors.add(:logo, 'is too large (maximum is 5MB)') if logo.blob.byte_size > 5.megabytes

    # Check content type
    acceptable_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
    return if acceptable_types.include?(logo.content_type)

    errors.add(:logo, 'must be a JPEG, PNG, GIF, or WebP image')
  end
end
