class CreateDefaultSponsor < ActiveRecord::Migration[7.0]
  def up
    # Create default sponsor if it doesn't exist
    default_sponsor = Sponsor.find_or_create_by!(company_name: 'Unassigned Sponsor') do |s|
      s.tier = 'Bronze'
      s.contact_email = 'admin@example.com'
      s.website = 'https://example.com'
      s.company_description = 'Default sponsor for users not yet assigned to a company'
      s.resume_access = false
    end

    # Assign all sponsor users without a sponsor to the default sponsor
    User.where(role: 'sponsor').includes(:sponsors).each do |user|
      SponsorUserJoin.create!(user: user, sponsor: default_sponsor) if user.sponsors.empty?
    end
  end

  def down
    default_sponsor = Sponsor.find_by(company_name: 'Unassigned Sponsor')
    default_sponsor&.destroy
  end
end
