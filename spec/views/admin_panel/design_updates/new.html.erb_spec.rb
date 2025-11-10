require 'rails_helper'

RSpec.describe 'admin_panel/design_updates/new.html.erb', type: :view do
  before do
    assign(:design_update, DesignUpdate.new)
    render
  end

  it 'displays the new form' do
    expect(rendered).to have_selector('form')
  end

  it 'has a title field' do
    expect(rendered).to have_field('Title')
  end

  it 'has an update_date field' do
    expect(rendered).to have_field('Date')
  end

  it 'has a pdf_file field' do
    expect(rendered).to have_field('Upload PDF')
  end

  it 'has a submit button' do
    expect(rendered).to have_button
  end

  it 'shows the file size requirement' do
    expect(rendered).to include('max 10MB')
  end
end
