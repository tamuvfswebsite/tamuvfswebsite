class Event < ApplicationRecord
  has_many :attendances, dependent: :destroy
  has_many :event_rsvps, dependent: :destroy
  has_many :event_organizational_roles, dependent: :destroy
  has_many :organizational_roles, through: :event_organizational_roles

  validates :title, presence: true, length: { minimum: 3 }
  validates :event_date, presence: true
  validates :location, presence: true
  validates :capacity, presence: true, numericality: { greater_than: 0 }

  validate :event_date_cannot_be_in_past, on: :create

  scope :future_events, -> { where('event_date > ?', Time.current) }
  scope :past_events, -> { where('event_date <= ?', Time.current) }
  scope :published, -> { where(is_published: true) }
  scope :public_events, -> { where(is_public: true) }
  scope :for_organizational_role, ->(role) { joins(:organizational_roles).where(organizational_roles: { id: role.id }) }
  scope :for_organizational_roles, lambda { |roles|
    joins(:organizational_roles).where(organizational_roles: { id: roles.map(&:id) })
  }
  # Events with no specific roles and not public - only visible to users with roles
  scope :for_all_roles, -> { where.not(id: EventOrganizationalRole.select(:event_id)).where(is_public: false) }

  # Scope to get events visible to a user based on their roles
  scope :visible_to_user, lambda { |user_roles = []|
    # Public events are visible to everyone
    public_scope = public_events

    # Events tagged with user's roles
    role_scope = if user_roles.any?
                   for_organizational_roles(user_roles)
                 else
                   none
                 end

    # Events with no specific roles (for_all_roles) - only visible to users WITH roles
    all_roles_scope = if user_roles.any?
                        for_all_roles
                      else
                        none
                      end

    # Combine: public events OR events for user's roles OR events for all roles (if user has roles)
    where(id: public_scope.select(:id))
      .or(where(id: role_scope.select(:id)))
      .or(where(id: all_roles_scope.select(:id)))
  }

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
