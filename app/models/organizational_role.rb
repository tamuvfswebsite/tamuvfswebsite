class OrganizationalRole < ApplicationRecord
  has_many :organizational_role_users, dependent: :destroy
  has_many :users, through: :organizational_role_users
  has_many :event_organizational_roles, dependent: :destroy
  has_many :events, through: :event_organizational_roles

  validates :name, presence: true, uniqueness: true
end
