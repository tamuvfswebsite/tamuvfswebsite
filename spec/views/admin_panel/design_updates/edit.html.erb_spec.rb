require 'rails_helper'

RSpec.describe 'admin_panel/design_updates/edit.html.erb', type: :view do
  let(:design_update) do
    tempfile = Tempfile.new(['test', '.pdf'])
    tempfile.write('%PDF-1.4 test content')
    tempfile.rewind

    du = DesignUpdate.create!(
      title: 'Test Update',
      update_date: Date.today,
      pdf_file: {
        io: tempfile,
        filename: 'test.pdf',
        content_type: 'application/pdf'
      }
    )

    tempfile.close
    tempfile.unlink
    du
  end

  before do
    assign(:design_update, design_update)
    render
  end

  it 'displays the edit form' do
    expect(rendered).to have_selector('form')
  end

  it 'has a title field' do
    expect(rendered).to have_field('Title', with: 'Test Update')
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

  it 'shows the current PDF file' do
    expect(rendered).to include('Current file:')
    expect(rendered).to include('test.pdf')
  end
end
