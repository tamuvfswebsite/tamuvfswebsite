class HomeController < ApplicationController
  def index
    # Redirect to homepage if signed in
    if admin_signed_in?
      redirect_to homepage_path
    end
  end

  def homepage
    # Redirect to landing page if not signed in
    unless admin_signed_in?
      redirect_to root_path
      return
    end

    # Post-login landing page
    @upcoming_events = Event.future_events.order(:event_date).limit(5)
    render :homepage, layout: 'application'
  end
end
