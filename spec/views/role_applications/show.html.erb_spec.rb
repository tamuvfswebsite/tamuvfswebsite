require 'rails_helper'

RSpec.describe "role_applications/show", type: :view do
  before(:each) do
    assign(:role_application, RoleApplication.create!(
      user: nil,
      org_role: "Org Role",
      essay: "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Org Role/)
    expect(rendered).to match(/MyText/)
  end
end
