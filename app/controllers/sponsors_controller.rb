class SponsorsController < ApplicationController
  before_action :ensure_sponsor_user
  before_action :set_sponsor

  def index
    @sponsors = Sponsor.all
  end

  def edit; end

  def update
    if @sponsor.update(sponsor_params)
      redirect_to sponsor_dashboard_index_path(@sponsor), notice: 'Your company profile was successfully updated.'
    else
      render :edit
    end
  end

  private

  def set_sponsor
    @sponsor = current_user.sponsors.first
  end

  def sponsor_params
    params.require(:sponsor).permit(
      :company_name,
      :website,
      :tier,
      :contact_email,
      :phone_number,
      :company_description
    )
  end
end
