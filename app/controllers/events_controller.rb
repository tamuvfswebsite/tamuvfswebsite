class EventsController < ApplicationController
  def index
    @events = Event.published.future_events.order(:event_date)
  end

  def show
    @event = Event.published.find(params[:id])
    rsvp_user = admin_signed_in? ? User.find_by(google_uid: current_admin.uid) : nil
    @rsvp = rsvp_user ? EventRsvp.find_by(event: @event, user: rsvp_user) : nil
    @yes_count = EventRsvp.where(event: @event, status: 'yes').count
    @no_count = EventRsvp.where(event: @event, status: 'no').count
    @maybe_count = EventRsvp.where(event: @event, status: 'maybe').count
  end
end
