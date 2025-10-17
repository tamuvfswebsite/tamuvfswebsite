module AdminPanel
  class EventsController < AdminPanel::BaseController
    before_action :find_event, only: %i[show edit update destroy]

    def index
      @upcoming_events = Event.future_events.order(:event_date)
      @past_events = Event.past_events.order(event_date: :desc)
    end

    def show
      rsvp_user = admin_signed_in? ? User.find_by(google_uid: current_admin.uid) : nil
      @rsvp = rsvp_user ? EventRsvp.find_by(event: @event, user: rsvp_user) : nil
      @yes_count = EventRsvp.where(event: @event, status: 'yes').count
      @no_count = EventRsvp.where(event: @event, status: 'no').count
      @maybe_count = EventRsvp.where(event: @event, status: 'maybe').count
    end

    def new
      @event = Event.new
    end

    def edit; end

    def create
      @event = Event.new(event_parameters)

      if @event.save
        redirect_to [:admin_panel, @event], notice: 'Event created successfully!'
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @event.update(event_parameters)
        redirect_to [:admin_panel, @event], notice: 'Event updated successfully!'
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @event.destroy
      redirect_to admin_panel_events_path, notice: 'Event deleted successfully!'
    end

    private

    def find_event
      @event = Event.find(params[:id])
    end

    def event_parameters
      params.require(:event).permit(:title, :description, :event_date, :location, :capacity, :attendance_points)
    end
  end
end
