class HomeController < ApplicationController
  def index
    # Simple index page - no authentication required for viewing
  end

  def homepage
    # Post-login landing page
    render :homepage, layout: 'application'
  end
end
