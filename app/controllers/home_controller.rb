class HomeController < ApplicationController
  helper_method :current_user

  def index
    # Redirect to homepage if signed in
    return unless admin_signed_in?

    redirect_to homepage_path
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

  def apply
    # Set session flag to indicate user is applying
    session[:applying_for_role] = true
    # Render a view that will POST to OAuth
    render :apply, layout: false
  end

  private

  def current_user
    return nil unless admin_signed_in?
    
    @current_user ||= User.find_by(google_uid: current_admin.uid)
  end
end
