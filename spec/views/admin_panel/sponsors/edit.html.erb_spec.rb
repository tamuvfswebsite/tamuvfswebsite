require 'rails_helper'

RSpec.describe 'admin_panel/sponsors/edit.html.erb', type: :view do
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

  it 'renders the edit sponsor header' do
    expect(rendered).to have_selector('h1', text: 'Edit Sponsor')
  end

  it 'renders the form with correct fields' do
    expect(rendered).to have_selector('form')
    expect(rendered).to have_field('Sponsor Company Name', with: 'TechCorp')
    expect(rendered).to have_field('Sponsor Website', with: 'https://techcorp.com')
  end

  it 'includes navigation links' do
    expect(rendered).to have_link('Show Sponsor', href: admin_panel_sponsor_path(sponsor))
    expect(rendered).to have_link('Back to Sponsors', href: admin_panel_sponsors_path)
  end
end
