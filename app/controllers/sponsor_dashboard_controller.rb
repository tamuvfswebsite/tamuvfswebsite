class SponsorDashboardController < ApplicationController
  before_action :ensure_sponsor_user

  def index
    @sponsor = current_user.primary_sponsor

    if @sponsor.nil?
      # This shouldn't happen due to the User model callback, but just in case
      @sponsor = Sponsor.default_sponsor
      current_user.sponsors << @sponsor
    end

    # Show a notice if they're on the default sponsor
    return unless @sponsor.default_sponsor?

    flash.now[:notice] = 'You are currently not assigned to a sponsor company. Please contact an administrator.'
  end
end
