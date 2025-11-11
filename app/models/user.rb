class User < ApplicationRecord
  has_one :resume, dependent: :destroy
  has_many :role_applications, dependent: :destroy
  has_many :sponsor_user_joins, dependent: :destroy
  has_many :sponsors, through: :sponsor_user_joins
  has_many :resume_downloads, dependent: :destroy
  belongs_to :organizational_role, optional: true

  scope :sponsor_role, -> { where(role: 'sponsor') }
  scope :non_sponsors, -> { where.not(role: 'sponsor') }

  has_many :organizational_role_users, dependent: :destroy
  has_many :organizational_roles, through: :organizational_role_users

  validates :google_uid, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  after_update :assign_to_default_sponsor_if_needed

  # Helper methods for user roles
  def sponsor?
    role == 'sponsor'
  end

  def admin?
    role == 'admin'
  end

  # Get the primary (only) sponsor for this user
  def primary_sponsor
    sponsors.first
  end

  private

  def assign_to_default_sponsor_if_needed
    return unless saved_change_to_role? && role == 'sponsor'
    return if sponsors.any?

    sponsors << Sponsor.default_sponsor
  end
end
