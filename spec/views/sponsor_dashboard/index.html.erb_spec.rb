require 'rails_helper'

RSpec.describe 'sponsor_dashboard/index.html.erb', type: :view do
  it 'renders the sponsor dashboard with expected links' do
    render

    expect(rendered).to include('Welcome, Sponsor')
    expect(rendered).to include('View student resumes')
    expect(rendered).to include('Logo Placements')
    expect(rendered).to include('Home')
  end
end
