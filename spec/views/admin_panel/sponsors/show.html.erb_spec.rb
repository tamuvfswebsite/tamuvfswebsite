require 'rails_helper'

RSpec.describe 'admin_panel/sponsors/show.html.erb', type: :view do
  let(:sponsor) do
    Sponsor.new(
      id: 1,
      company_name: 'TechCorp',
      website: 'https://techcorp.com',
      tier: 'Gold',
      contact_email: 'contact@techcorp.com',
      phone_number: '123-456-7890',
      company_description: 'A great tech company.',
      resume_access: true
    )
  end

  before do
    assign(:sponsor, sponsor)
    render
  end

  it 'shows sponsor details' do
    expect(rendered).to include('TechCorp')
    expect(rendered).to include('https://techcorp.com')
    expect(rendered).to include('Gold')
    expect(rendered).to include('Yes') # resume_access
  end

  it 'includes navigation links' do
    expect(rendered).to have_link('Edit Sponsor', href: edit_admin_panel_sponsor_path(sponsor))
    expect(rendered).to have_link('Back to Sponsors', href: admin_panel_sponsors_path)
  end
end
