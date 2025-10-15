class SponsorUserJoin < ApplicationRecord
  belongs_to :user
  belongs_to :sponsor

  validate :user_must_be_sponsor

  private

  def user_must_be_sponsor
    errors.add(:user, "must have role 'sponsor'") unless user.role == 'sponsor'
  end
end