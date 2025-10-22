require 'rails_helper'

RSpec.describe 'admin_panel/events/index.html.erb', type: :view do
  let!(:upcoming_event) do
    Event.create!(
      title: 'Future Event',
      event_date: 1.day.from_now,
      location: 'MSC',
      capacity: 100,
      attendance_points: 10
    )
  end

  before do
    assign(:upcoming_events, [upcoming_event])
    assign(:past_events, []) # just skip past events
    render
  end

  it 'shows upcoming events' do
    expect(rendered).to include('Future Event')
  end
end
