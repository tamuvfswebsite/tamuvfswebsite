class HomeController < ApplicationController
  def index
    # Load user data if signed in
    if admin_signed_in?
      rsvp_user = User.find_by(google_uid: current_admin.uid)
      @user_roles = rsvp_user&.organizational_roles || []
    else
      @user_roles = []
    end

    # Filter events based on user roles (AC3, AC5)
    base_events = Event.published.future_events
    @upcoming_events = if admin_user?
                         # Admins see all events
                         base_events.order(:event_date).limit(5)
                       else
                         # Regular users see only events relevant to their roles or public events
                         base_events.visible_to_user(@user_roles).distinct.order(:event_date).limit(5)
                       end
  end

  def apply
    # Set session flag to indicate user is applying
    session[:applying_for_role] = true
    # Render a view that will POST to OAuth
    render :apply, layout: false
  end
end
