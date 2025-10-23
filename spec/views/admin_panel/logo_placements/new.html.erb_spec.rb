require 'rails_helper'

RSpec.describe 'admin_panel/logo_placements/new', type: :view do
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
    assign(:logo_placement, sponsor.logo_placements.new(
                              page_name: 'MyString',
                              section: 'MyString',
                              displayed: false
                            ))
  end

  it 'renders new logo_placement form' do
    render

    assert_select 'form[action=?][method=?]', admin_panel_sponsor_logo_placements_path(sponsor), 'post' do
      assert_select 'input[name=?]', 'logo_placement[page_name]'
      assert_select 'input[name=?]', 'logo_placement[section]'
      assert_select 'input[name=?]', 'logo_placement[displayed]'
    end
  end
end
