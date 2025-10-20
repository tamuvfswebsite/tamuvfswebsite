module AdminPanel
  class RoleApplicationsController < BaseController
    before_action :set_role_application, only: %i[show destroy update_status]

    def index
      @role_applications = RoleApplication.includes(:user, :organizational_role)

      # Filter by status if provided
      if params[:status].present?
        selected_statuses = params[:status].select { |_k, v| v == '1' }.keys
        @role_applications = @role_applications.where(status: selected_statuses) if selected_statuses.any?
      end

      @role_applications = @role_applications.order(created_at: :desc)
    end

    def show
      # Display full application details
    end

    def update_status
      if @role_application.update(status: params.dig(:role_application, :status))
        redirect_to admin_panel_role_applications_path, notice: 'Status updated successfully.'
      else
        redirect_to admin_panel_role_applications_path, alert: 'Failed to update status.'
      end
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
