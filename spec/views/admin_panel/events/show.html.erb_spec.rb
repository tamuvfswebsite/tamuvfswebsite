require 'rails_helper'

RSpec.describe 'admin_panel/events/show.html.erb', type: :view do
  let(:event) do
    Event.create!(title: 'Tech Talk', description: 'AI in 2025', event_date: 1.day.from_now, location: 'MSC',
                  capacity: 100, attendance_points: 5)
  end

  before do
    assign(:event, event)
    assign(:yes_count, 5)
    assign(:maybe_count, 2)
    assign(:no_count, 1)
    assign(:rsvps, [])
    assign(:attendances, [])
    assign(:attended_count, 0)
    assign(:total_rsvps_yes, 0)
    render
  end

  it 'displays the event details' do
    expect(rendered).to include('Tech Talk')
    expect(rendered).to include('AI in 2025')
    expect(rendered).to include('MSC')
  end

  it 'shows RSVP open message for future events' do
    expect(rendered).to include('RSVP is currently open')
  end
end
