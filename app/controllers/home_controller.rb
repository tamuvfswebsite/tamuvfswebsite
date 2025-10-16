class HomeController < ApplicationController
  def index
    # Simple index page - no authentication required for viewing
  end

  def homepage
    # Post-login landing page
    @upcoming_events = Event.future_events.order(:event_date).limit(5)
    render :homepage, layout: 'application'
  end
end
