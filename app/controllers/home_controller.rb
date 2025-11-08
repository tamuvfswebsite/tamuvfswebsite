class HomeController < ApplicationController
  def index
    # Load events for everyone
    @upcoming_events = Event.published.future_events.order(:event_date).limit(5)

    # Load user data if signed in (for future use)
    return unless admin_signed_in?

    rsvp_user = User.find_by(google_uid: current_admin.uid)
    @user_roles = rsvp_user&.organizational_roles || []
  end

  def apply
    # Set session flag to indicate user is applying
    session[:applying_for_role] = true
    # Render a view that will POST to OAuth
    render :apply, layout: false
  end
end
