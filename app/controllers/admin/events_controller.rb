class Admin::EventsController < Admin::BaseController
  before_action :find_event, only: [:show, :edit, :update, :destroy]

  def index
    @upcoming_events = Event.future_events.order(:event_date)
    @past_events = Event.past_events.order(event_date: :desc)
  end

  def show
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_parameters)
    
    if @event.save
      redirect_to [:admin, @event], notice: 'Event created successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_parameters)
      redirect_to [:admin, @event], notice: 'Event updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to admin_events_path, notice: 'Event deleted successfully!'
  end

  private

  def find_event
    @event = Event.find(params[:id])
  end

  def event_parameters
    params.require(:event).permit(:title, :description, :event_date, :location, :capacity)
  end
end