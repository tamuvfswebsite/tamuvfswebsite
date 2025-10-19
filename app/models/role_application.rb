class RoleApplication < ApplicationRecord
  belongs_to :user
  belongs_to :organizational_role, foreign_key: :org_role_id, optional: false

  validates :essay, presence: true, length: { minimum: 50 }
  validates :user_id, uniqueness: { message: 'has already submitted an application' }
  
  validate :user_must_have_resume

  private

  def user_must_have_resume
    return if user&.resume&.file&.attached?

    errors.add(:base, 'You must upload a resume before submitting an application')
  end
end
