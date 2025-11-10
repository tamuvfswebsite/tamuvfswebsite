class SponsorsController < ApplicationController
  before_action :ensure_sponsor_user
  before_action :set_sponsor

  def index
    @sponsors = Sponsor.all
  end

  def edit
    return unless @sponsor.nil? || @sponsor.default_sponsor?

    redirect_to sponsor_dashboard_index_path,
                alert:
                'You cannot edit this sponsor profile. Please contact an administrator to be assigned to a company.'
  end

  def update
    if @sponsor.nil? || @sponsor.default_sponsor?
      redirect_to sponsor_dashboard_index_path,
                  alert: 'You cannot edit the default sponsor profile.'
      return
    end

    if @sponsor.update(sponsor_params)
      redirect_to sponsor_dashboard_index_path,
                  notice: 'Your company profile was successfully updated.'
    else
      render :edit
    end
  end

  private

  def set_sponsor
    @sponsor = current_user.primary_sponsor

    # Assign to default sponsor if none exists
    return unless @sponsor.nil?

    default = Sponsor.default_sponsor
    current_user.sponsors << default
    @sponsor = default
  end

  def sponsor_params
    params.require(:sponsor).permit(
      :company_name,
      :website,
      :tier,
      :contact_email,
      :phone_number,
      :company_description,
      :logo
    )
  end
end
