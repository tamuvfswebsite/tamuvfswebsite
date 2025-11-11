class RoleApplication < ApplicationRecord
  belongs_to :user
  belongs_to :organizational_role, foreign_key: :org_role_id

  enum :status, {
    not_reviewed: 0,
    in_review: 1,
    interview_needed: 2,
    accepted: 3,
    rejected: 4
  }, default: :not_reviewed

  validates :answer_1, presence: true, length: { minimum: 50 },
                       if: -> { organizational_role&.question_1.present? }
  validates :answer_2, presence: true, length: { minimum: 50 },
                       if: -> { organizational_role&.question_2.present? }
  validates :answer_3, presence: true, length: { minimum: 50 },
                       if: -> { organizational_role&.question_3.present? }

  validate :user_must_have_resume
  validate :user_application_limit

  # Auto-update user's organizational role when application is accepted
  after_update :update_user_organizational_role, if: :saved_change_to_status?

  private

  def user_must_have_resume
    return if user&.resume&.file&.attached?

    errors.add(:base, 'You must upload a resume before submitting an application')
  end

  def user_application_limit
    return unless user

    # Allow unlimited if updating existing record
    return if persisted?

    return unless user.role_applications.count >= 10

    errors.add(:base, 'You have reached the maximum limit of 10 applications')
  end

  def update_user_organizational_role
    return unless accepted?

    # Add the organizational role to user's roles (don't replace existing ones)
    user.organizational_roles << organizational_role unless user.organizational_roles.include?(organizational_role)

    # If user doesn't have a primary organizational role yet, set this as primary
    user.update(organizational_role_id: org_role_id) if user.organizational_role_id.nil?
  end
end
