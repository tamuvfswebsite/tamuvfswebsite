class OrganizationalRoleUser < ApplicationRecord
  belongs_to :user
  belongs_to :organizational_role

  validates :user_id, uniqueness: { scope: :organizational_role_id }
end
