class EventRsvp < ApplicationRecord
  STATUSES = %w[yes no maybe].freeze

  belongs_to :event
  belongs_to :user

  validates :status, inclusion: { in: STATUSES }
end
