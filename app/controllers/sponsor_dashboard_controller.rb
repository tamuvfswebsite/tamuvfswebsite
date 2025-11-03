class SponsorDashboardController < ApplicationController
  before_action :ensure_sponsor_user

  def index
    @sponsor = current_sponsor
    
    if @sponsor.nil?
      flash[:alert] = 'No sponsor company associated with your account.'
      redirect_to homepage_path
    end
  end
end