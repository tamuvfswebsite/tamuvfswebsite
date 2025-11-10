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
                  notice: 'Sponsor was successfully deleted. Associated users were moved to the default sponsor.'
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

    def assign_users_to_sponsor(user_ids)
      default_sponsor = Sponsor.default_sponsor
      
      # Clear existing assignments for this sponsor
      @sponsor.users.each do |user|
        user.sponsors.clear
      end

      # Assign selected users to this sponsor
      if user_ids.any?
        users = User.where(id: user_ids, role: 'sponsor')
        users.each do |user|
          # Clear any existing sponsor assignments
          user.sponsors.clear
          # Assign to this sponsor
          user.sponsors << @sponsor
        end
      end

      # Ensure all sponsor users without a sponsor get assigned to default
      User.where(role: 'sponsor').includes(:sponsors).each do |user|
        if user.sponsors.empty?
          user.sponsors << default_sponsor
        end
      end
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