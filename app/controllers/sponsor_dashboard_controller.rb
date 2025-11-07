class SponsorDashboardController < ApplicationController
  before_action :ensure_sponsor_user

  def index
    @sponsor = current_sponsor

    return unless @sponsor.nil?

    flash[:alert] = 'No sponsor company associated with your account.'
    redirect_to root_path
  end
end
