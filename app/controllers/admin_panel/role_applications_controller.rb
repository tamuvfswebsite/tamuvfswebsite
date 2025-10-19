module AdminPanel
  class RoleApplicationsController < BaseController
    before_action :set_role_application, only: %i[show destroy]

    def index
      @role_applications = RoleApplication.includes(:user, :organizational_role).order(created_at: :desc)
    end

    def show
      # Display full application details
    end

    def destroy
      @role_application.destroy!
      redirect_to admin_panel_role_applications_path, notice: 'Application was successfully deleted.'
    end

    private

    def set_role_application
      @role_application = RoleApplication.find(params[:id])
    end
  end
end
