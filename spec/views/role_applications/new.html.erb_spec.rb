require 'rails_helper'

RSpec.describe "role_applications/new", type: :view do
  before(:each) do
    assign(:role_application, RoleApplication.new(
      user: nil,
      org_role: "MyString",
      essay: "MyText"
    ))
  end

  it "renders new role_application form" do
    render

    assert_select "form[action=?][method=?]", role_applications_path, "post" do

      assert_select "input[name=?]", "role_application[user_id]"

      assert_select "input[name=?]", "role_application[org_role]"

      assert_select "textarea[name=?]", "role_application[essay]"
    end
  end
end
