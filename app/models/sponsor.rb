class Sponsor < ApplicationRecord
  validates :company_name, presence: true, uniqueness: true
  has_many :sponsor_user_joins, dependent: :destroy
  has_many :users, through: :sponsor_user_joins
  has_many :logo_placements, class_name: 'AdminPanel::LogoPlacement', dependent: :destroy

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
    return super if default_sponsor?

    default = self.class.default_sponsor
    users.each do |user|
      user.sponsors.clear
      user.sponsors << default unless user.sponsors.include?(default)
    end
    super
  end
end