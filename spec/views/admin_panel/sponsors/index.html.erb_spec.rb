require 'rails_helper'

RSpec.describe 'admin_panel/sponsors/index.html.erb', type: :view do
  let(:sponsor1) { Sponsor.new(id: 1, company_name: 'TechCorp', website: 'https://techcorp.com', tier: 'Gold') }
  let(:sponsor2) { Sponsor.new(id: 2, company_name: 'DataWorks', website: 'https://dataworks.ai', tier: 'Silver') }

  before do
    assign(:sponsors, [sponsor1, sponsor2])
    render
  end

  it 'renders the sponsor management header' do
    expect(rendered).to have_selector('h1', text: 'Sponsor Management')
  end

  it 'displays sponsor company names' do
    expect(rendered).to include('TechCorp')
    expect(rendered).to include('DataWorks')
  end

  it 'renders action links for each sponsor' do
    expect(rendered).to have_link('Edit', href: edit_admin_panel_sponsor_path(sponsor1))
    expect(rendered).to have_button('Delete')
  end

  it 'has a link to create a new sponsor' do
    expect(rendered).to have_link('Create New Sponsor', href: new_admin_panel_sponsor_path)
  end
end
