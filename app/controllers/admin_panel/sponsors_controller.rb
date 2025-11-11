module AdminPanel
  class SponsorsController < BaseController
    before_action :set_sponsor, only: %i[show edit update destroy assign_users update_users remove_logo]

    def index
      @sponsors = Sponsor.all.order(:company_name)
    end

    def show; end

    def new
      @sponsor = Sponsor.new
    end

    def edit; end

    def create
      @sponsor = Sponsor.new(sponsor_params)
      if @sponsor.save
        redirect_to admin_panel_sponsor_path(@sponsor), notice: 'Sponsor was successfully created.'
      else
        render :new
      end
    end

    def update
      if @sponsor.update(sponsor_params)
        redirect_to admin_panel_sponsor_path(@sponsor), notice: 'Sponsor was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      if @sponsor.default_sponsor?
        redirect_to admin_panel_sponsors_path,
                    alert: 'Cannot delete the default sponsor.'
        return
      end

      @sponsor.destroy
      redirect_to admin_panel_sponsors_path,
                  notice:
                  'Sponsor was successfully deleted. Associated users were moved to the default sponsor.'
    end

    def remove_logo
      if @sponsor.logo.attached?
        @sponsor.logo.purge
        redirect_to edit_admin_panel_sponsor_path(@sponsor), notice: 'Logo was successfully removed.'
      else
        redirect_to edit_admin_panel_sponsor_path(@sponsor), alert: 'No logo to remove.'
      end
    end

    def assign_users
      @available_users = User.where(role: 'sponsor')
      @assigned_users = @sponsor.users
    end

    def update_users
      user_ids = extract_user_ids
      AdminPanel::SponsorUserAssigner.new(@sponsor, user_ids).call
      redirect_success
    rescue StandardError => e
      redirect_failure(e)
    end

    private

    def set_sponsor
      @sponsor = Sponsor.find(params[:id])
    end

    def sponsor_params
      params.require(:sponsor).permit(
        :company_name,
        :website,
        :tier,
        :contact_email,
        :phone_number,
        :company_description,
        :resume_access,
        :logo
      )
    end

    def extract_user_ids
      params.dig(:sponsor, :user_ids)&.reject(&:blank?) || []
    end

    def redirect_success
      redirect_to admin_panel_sponsor_path(@sponsor),
                  notice: "Users updated successfully. #{@sponsor.users.count} user(s) assigned."
    end

    def redirect_failure(exception)
      redirect_to assign_users_admin_panel_sponsor_path(@sponsor),
                  alert: "Error updating users: #{exception.message}"
    end
  end
end
