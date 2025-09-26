class Admin::DashboardController < Admin::BaseController
  def index
    # @total_users = User.count
    # @upcoming_events = Event.where('date >= ?', Time.current).order(:date).limit(5)
    # @recent_applications = Application.order(created_at: :desc).limit(5)
    # @resume_count = Resume.count
  end
end
