class User < ApplicationRecord
  has_one :resume, dependent: :destroy
  belongs_to :organizational_role, optional: true
  has_many :sponsor_user_joins
  has_many :sponsors, through: :sponsor_user_joins
  scope :sponsor_role, -> { where(role: 'sponsor') }

  validates :google_uid, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
end
