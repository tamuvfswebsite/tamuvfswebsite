require 'rails_helper'

RSpec.describe 'role_applications/index', type: :view do
  before(:each) do
    assign(:role_applications, [
             RoleApplication.create!(
               user: nil,
               org_role: 'Org Role',
               essay: 'MyText'
             ),
             RoleApplication.create!(
               user: nil,
               org_role: 'Org Role',
               essay: 'MyText'
             )
           ])
  end

  it 'renders a list of role_applications' do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new('Org Role'.to_s), count: 2
    assert_select cell_selector, text: Regexp.new('MyText'.to_s), count: 2
  end
end
