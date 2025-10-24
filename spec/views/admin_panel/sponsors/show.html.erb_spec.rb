require 'rails_helper'

RSpec.describe 'admin_panel/sponsors/show.html.erb', type: :view do
  let(:sponsor) { Sponsor.new(id: 1, company_name: 'TechCorp', website: 'https://techcorp.com', logo_url: 'logo.png', resume_access: true) }

  before do
    assign(:sponsor, sponsor)
    render
  end

  it 'shows sponsor details' do
    expect(rendered).to include('TechCorp')
    expect(rendered).to include('https://techcorp.com')
    expect(rendered).to include('logo.png')
    expect(rendered).to include('Yes')
  end

  it 'includes navigation links' do
    expect(rendered).to have_link('Edit Sponsor', href: edit_admin_panel_sponsor_path(sponsor))
    expect(rendered).to have_link('Back to Sponsors', href: admin_panel_sponsors_path)
  end
end
