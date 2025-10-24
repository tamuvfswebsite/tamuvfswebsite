require 'rails_helper'

RSpec.describe 'admin_panel/logo_placements/show', type: :view do
  let(:sponsor) do
    Sponsor.create!(
      company_name: 'Test Company',
      website: 'https://example.com',
      logo_url: 'https://example.com/logo.png',
      resume_access: false
    )
  end

  before(:each) do
    assign(:sponsor, sponsor)
    assign(:logo_placement, sponsor.logo_placements.create!(
                              page_name: 'Page Name',
                              section: 'Section',
                              displayed: false
                            ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Page Name/)
    expect(rendered).to match(/Section/)
  end
end
