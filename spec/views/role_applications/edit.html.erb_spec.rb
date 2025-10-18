require 'rails_helper'

RSpec.describe "role_applications/edit", type: :view do
  let(:role_application) {
    RoleApplication.create!(
      user: nil,
      org_role: "MyString",
      essay: "MyText"
    )
  }

  before(:each) do
    assign(:role_application, role_application)
  end

  it "renders the edit role_application form" do
    render

    assert_select "form[action=?][method=?]", role_application_path(role_application), "post" do

      assert_select "input[name=?]", "role_application[user_id]"

      assert_select "input[name=?]", "role_application[org_role]"

      assert_select "textarea[name=?]", "role_application[essay]"
    end
  end
end
