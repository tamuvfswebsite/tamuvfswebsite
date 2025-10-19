class User < ApplicationRecord
  has_one :resume, dependent: :destroy
  has_one :role_application, dependent: :destroy
  has_many :organizational_role_users, dependent: :destroy
  has_many :organizational_roles, through: :organizational_role_users

  validates :google_uid, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
end
