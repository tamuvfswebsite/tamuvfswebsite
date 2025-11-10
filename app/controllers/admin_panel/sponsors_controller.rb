module AdminPanel
  class SponsorsController < BaseController
    before_action :set_sponsor, only: %i[show edit update destroy assign_users update_users]

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

    def assign_users
      @available_users = User.where(role: 'sponsor')
      @assigned_users = @sponsor.users
    end

    def update_users
      user_ids = extract_user_ids
      assign_users_to_sponsor(user_ids)
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
        :resume_access
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

    def assign_users_to_sponsor(user_ids)
      @sponsor = find_sponsor # assuming @sponsor is set elsewhere, or pass as param
      default_sponsor = Sponsor.default_sponsor

      clear_existing_assignments
      assign_selected_users(user_ids)
      assign_unassigned_sponsor_users(default_sponsor)
    end

    def clear_existing_assignments
      @sponsor.users.find_each do |user|
        user.sponsors.clear
      end
    end

    def assign_selected_users(user_ids)
      return unless user_ids.any?

      User.where(id: user_ids, role: 'sponsor').find_each do |user|
        user.sponsors.clear
        user.sponsors << @sponsor
      end
    end

    def assign_unassigned_sponsor_users(default_sponsor)
      User.where(role: 'sponsor')
          .left_joins(:sponsors)
          .where(sponsors: { id: nil })
          .find_each do |user|
        user.sponsors << default_sponsor
      end
    end
  end
end
