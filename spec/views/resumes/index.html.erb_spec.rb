require 'rails_helper'

RSpec.describe 'resumes/index', type: :view do
  before(:each) do
    assign(:resumes, [
             Resume.create!(
               user: nil
             ),
             Resume.create!(
               user: nil
             )
           ])
  end

  it 'renders a list of resumes' do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
