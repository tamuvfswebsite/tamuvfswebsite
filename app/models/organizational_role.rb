class OrganizationalRole < ApplicationRecord
  has_many :organizational_role_users, dependent: :destroy
  has_many :users, through: :organizational_role_users

  validates :name, presence: true, uniqueness: true
end
