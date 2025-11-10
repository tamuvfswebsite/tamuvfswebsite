require 'csv'

module AdminPanel
  class RoleApplicationsController < BaseController
    before_action :set_role_application, only: %i[show destroy update_status]

    # rubocop:disable Metrics/AbcSize
    def index
      @role_applications = RoleApplication.includes(:user, :organizational_role)

      # Filter by status if provided
      if params[:status].present?
        selected_statuses = params[:status].select { |_k, v| v == '1' }.keys
        @role_applications = @role_applications.where(status: selected_statuses) if selected_statuses.any?
      end

      @role_applications = @role_applications.order(created_at: :desc)

      respond_to do |format|
        format.html
        format.csv do
          send_data generate_csv(@role_applications),
                    filename: "role_applications_#{Time.zone.today}.csv",
                    type: 'text/csv'
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

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

    def generate_csv(applications)
      CSV.generate(headers: true) do |csv|
        csv << csv_headers
        applications.each { |app| csv << csv_row(app) }
      end
    end

    def csv_headers
      [
        'Applicant Name', 'Email', 'Role', 'Status',
        'Submitted Date', 'Last Updated',
        'Question 1', 'Answer 1', 'Question 2', 'Answer 2', 'Question 3', 'Answer 3'
      ]
    end

    # rubocop:disable Metrics/AbcSize
    def csv_row(app)
      [
        "#{app.user.first_name} #{app.user.last_name}",
        app.user.email,
        app.organizational_role.name,
        app.status.humanize,
        app.created_at.strftime('%Y-%m-%d %H:%M'),
        app.updated_at.strftime('%Y-%m-%d %H:%M'),
        app.organizational_role.question_1 || '',
        app.answer_1 || '',
        app.organizational_role.question_2 || '',
        app.answer_2 || '',
        app.organizational_role.question_3 || '',
        app.answer_3 || ''
      ]
    end
    # rubocop:enable Metrics/AbcSize
  end
end
