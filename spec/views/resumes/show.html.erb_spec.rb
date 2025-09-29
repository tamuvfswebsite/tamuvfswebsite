require 'rails_helper'

RSpec.describe 'resumes/show', type: :view do
  before(:each) do
    assign(:resume, Resume.create!(
                      user: nil
                    ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(//)
  end
end
