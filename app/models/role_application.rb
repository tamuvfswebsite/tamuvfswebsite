class RoleApplication < ApplicationRecord
  belongs_to :user
  belongs_to :organizational_role, foreign_key: :org_role_id

  enum :status, {
    not_reviewed: 0,
    in_review: 1,
    accepted: 2,
    rejected: 3
  }, default: :not_reviewed

  validates :answer_1, presence: true, length: { minimum: 50 }, 
            if: -> { organizational_role&.question_1.present? }
  validates :answer_2, presence: true, length: { minimum: 50 }, 
            if: -> { organizational_role&.question_2.present? }
  validates :answer_3, presence: true, length: { minimum: 50 }, 
            if: -> { organizational_role&.question_3.present? }
  
  validates :user_id, uniqueness: { message: 'has already submitted an application' }
  validate :user_must_have_resume

  private

  def user_must_have_resume
    return if user&.resume&.file&.attached?

    errors.add(:base, 'You must upload a resume before submitting an application')
  end
end
