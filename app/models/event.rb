class Event < ApplicationRecord
  validates :title, presence: true, length: { minimum: 3 }
  validates :event_date, presence: true
  validates :location, presence: true
  validates :capacity, presence: true, numericality: { greater_than: 0 }

  validate :event_date_cannot_be_in_past

  scope :future_events, -> { where('event_date > ?', Time.current) }
  scope :past_events, -> { where('event_date <= ?', Time.current) }
  scope :published, -> { where(is_published: true) }

  def formatted_date
    event_date&.strftime('%B %d, %Y at %I:%M %p')
  end

  def upcoming?
    event_date > Time.current
  end

  private

  def event_date_cannot_be_in_past
    return unless event_date.present? && event_date < Time.current

    errors.add(:event_date, "can't be in the past")
  end
end
