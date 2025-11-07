require 'rails_helper'

RSpec.describe 'sponsor_dashboard/index.html.erb', type: :view do
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

  it 'renders the sponsor dashboard with expected links and info' do
    expect(rendered).to include('Welcome, TechCorp')
    expect(rendered).to include('Access Resumes') # <-- updated text
    expect(rendered).to include('Edit Company Info')
    expect(rendered).to include('Home')
  end
end
