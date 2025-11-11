class EventsController < ApplicationController
  def index
    base_events = Event.published.future_events
    load_user_roles
    @organizational_roles = OrganizationalRole.all.order(:name)
    @events = filter_events(base_events)
  end

  def show
    @event = Event.published.find(params[:id])

    unless can_view_event?(@event)
      flash[:alert] = "You don't have permission to view this event."
      redirect_to events_path
      return
    end

    load_rsvp_data
    load_user_roles
  end

  private

  def load_user_roles
    if admin_signed_in?
      rsvp_user = User.find_by(google_uid: current_admin.uid)
      @user_roles = rsvp_user&.organizational_roles || []
    else
      @user_roles = []
    end
  end

  def filter_events(base_events)
    return base_events.order(:event_date) if admin_user?
    return filter_by_role_param(base_events) if params[:organizational_role_id].present?

    base_events.visible_to_user(@user_roles).distinct.order(:event_date)
  end

  def filter_by_role_param(base_events)
    role = OrganizationalRole.find_by(id: params[:organizational_role_id])
    return events_for_role(base_events, role) if role

    events_without_role_filter(base_events)
  end

  def events_for_role(base_events, role)
    base_events.for_organizational_role(role)
               .or(base_events.public_events)
               .distinct
               .order(:event_date)
  end

  def events_without_role_filter(base_events)
    if @user_roles.any?
      base_events.public_events
                 .or(base_events.for_all_roles)
                 .distinct
                 .order(:event_date)
    else
      base_events.public_events.distinct.order(:event_date)
    end
  end

  def load_rsvp_data
    rsvp_user = admin_signed_in? ? User.find_by(google_uid: current_admin.uid) : nil
    @rsvp = rsvp_user ? EventRsvp.find_by(event: @event, user: rsvp_user) : nil
    @yes_count = EventRsvp.where(event: @event, status: 'yes').count
    @no_count = EventRsvp.where(event: @event, status: 'no').count
    @maybe_count = EventRsvp.where(event: @event, status: 'maybe').count
  end

  def can_view_event?(event)
    return true if admin_user? || event.is_public?

    user_roles = current_user_roles
    return user_roles.any? if event.organizational_roles.empty?

    (event.organizational_roles & user_roles).any?
  end

  def current_user_roles
    return [] unless admin_signed_in?

    rsvp_user = User.find_by(google_uid: current_admin.uid)
    rsvp_user&.organizational_roles || []
  end
end
