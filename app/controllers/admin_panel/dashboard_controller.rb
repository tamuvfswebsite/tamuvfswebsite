module AdminPanel
  class DashboardController < AdminPanel::BaseController
    def index
      @total_users = User.count
      @total_events = Event.count
      @upcoming_events = Event.where('event_date >= ?', Time.current).order(:event_date).limit(5)
      @recent_events = Event.order(created_at: :desc).limit(5)
      # @recent_applications = Application.order(created_at: :desc).limit(5)
      @resume_count = Resume.count
      @sponsor_download_stats = ResumeDownload.sponsor_statistics
    end

    def leaderboard
      @leaders = User.order(points: :desc, last_name: :asc, first_name: :asc).limit(100)
    end
  end
end
