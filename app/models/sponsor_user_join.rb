class SponsorUserJoin < ApplicationRecord
  belongs_to :user
  belongs_to :sponsor

  validate :user_must_be_sponsor
  validate :user_can_only_have_one_sponsor

  private

  def user_must_be_sponsor
    errors.add(:user, "must have role 'sponsor'") unless user&.role == 'sponsor'
  end

  def user_can_only_have_one_sponsor
    return if user.nil? || sponsor.nil?
    
    # Allow if this is a persisted record (editing existing join)
    return if persisted?
    
    # Check if user already has a sponsor
    if user.sponsors.exists?
      errors.add(:user, "can only be assigned to one sponsor at a time")
    end
  end
end