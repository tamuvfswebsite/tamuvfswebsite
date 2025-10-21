require 'rails_helper'

RSpec.describe "admin_panel/logo_placements/index", type: :view do
  before(:each) do
    assign(:admin_panel_logo_placements, [
      AdminPanel::LogoPlacement.create!(
        sponsor: nil,
        page_name: "Page Name",
        section: "Section",
        displayed: false
      ),
      AdminPanel::LogoPlacement.create!(
        sponsor: nil,
        page_name: "Page Name",
        section: "Section",
        displayed: false
      )
    ])
  end

  it "renders a list of admin_panel/logo_placements" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Page Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Section".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(false.to_s), count: 2
  end
end
