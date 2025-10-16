class OrganizationalRole < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
