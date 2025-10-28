class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, omniauth_providers: [:google_oauth2]

  def self.from_google(email:, full_name:, uid:, avatar_url:)
    admin = find_or_initialize_by(email: email)
    admin.assign_attributes(
      uid: uid,
      full_name: full_name,
      avatar_url: avatar_url
    )
    admin.save!
    admin
  end
end
