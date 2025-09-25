require 'rails_helper'

RSpec.describe 'users/index', type: :view do
  before(:each) do
    assign(:users, [
             User.create!(
               first_name: 'First Name',
               last_name: 'Last Name',
               email: 'Email',
               role: 'Role'
             ),
             User.create!(
               first_name: 'First Name',
               last_name: 'Last Name',
               email: 'Email',
               role: 'Role'
             )
           ])
  end

  it 'renders a list of users' do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new('First Name'.to_s), count: 2
    assert_select cell_selector, text: Regexp.new('Last Name'.to_s), count: 2
    assert_select cell_selector, text: Regexp.new('Email'.to_s), count: 2
    assert_select cell_selector, text: Regexp.new('Role'.to_s), count: 2
  end
end
