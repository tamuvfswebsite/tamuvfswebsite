class EventOrganizationalRole < ApplicationRecord
  belongs_to :event
  belongs_to :organizational_role

  validates :event_id, uniqueness: { scope: :organizational_role_id }
end
