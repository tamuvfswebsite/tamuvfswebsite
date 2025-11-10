require 'rails_helper'

RSpec.describe 'admin_panel/sponsors/new.html.erb', type: :view do
  let(:sponsor) { Sponsor.new }

  before do
    assign(:sponsor, sponsor)
    render
  end

  it 'renders the new sponsor header' do
    expect(rendered).to have_selector('h1', text: 'Create New Sponsor')
  end

  it 'renders the sponsor form' do
    expect(rendered).to have_selector('form')
    expect(rendered).to have_field('Sponsor Company Name')
  end

  it 'includes navigation back to sponsors' do
    expect(rendered).to have_button('Back to Sponsors')
  end
end
