class EventRsvpsController < ApplicationController
  before_action :require_login
  before_action :set_event
  before_action :ensure_event_open

  def create
    upsert_rsvp!
    redirect_to @event, notice: 'RSVP saved.'
  end

  def update
    upsert_rsvp!
    redirect_to @event, notice: 'RSVP updated.'
  end

  private

  def require_login
    return if admin_signed_in?

    redirect_to new_admin_session_path, alert: 'Please sign in first.'
  end

  def set_event
    @event = Event.published.find(params[:event_id])
  end

  def upsert_rsvp!
    user = User.find_by(google_uid: current_admin.uid)
    rsvp = EventRsvp.find_or_initialize_by(event: @event, user: user)
    rsvp.status = params.require(:status)
    rsvp.save!
  end

  def ensure_event_open
    return if @event.event_date > Time.current

    redirect_to @event, alert: 'RSVP is closed for this event.'
  end
end
