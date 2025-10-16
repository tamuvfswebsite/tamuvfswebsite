module AdminPanel
  class AttendanceLinksController < AdminPanel::BaseController
    def new
      @events = Event.future_events.order(:event_date)
    end

    def create
      event = Event.find(params.require(:event_id))
      token = event.signed_id(purpose: 'checkin', expires_in: 30.minutes)
      link  = checkin_url(token: token)

      redirect_to admin_panel_events_path, notice: "Attendance link created: #{link}"
    end
  end
end


