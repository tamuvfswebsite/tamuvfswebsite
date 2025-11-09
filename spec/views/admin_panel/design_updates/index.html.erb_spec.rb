require 'rails_helper'

RSpec.describe 'admin_panel/design_updates/index.html.erb', type: :view do
  let(:design_updates) do
    tempfile1 = Tempfile.new(['test1', '.pdf'])
    tempfile1.write('%PDF-1.4 test')
    tempfile1.rewind

    tempfile2 = Tempfile.new(['test2', '.pdf'])
    tempfile2.write('%PDF-1.4 test')
    tempfile2.rewind

    updates = [
      DesignUpdate.create!(
        title: 'Update 1',
        update_date: Date.today,
        pdf_file: {
          io: tempfile1,
          filename: 'test1.pdf',
          content_type: 'application/pdf'
        }
      ),
      DesignUpdate.create!(
        title: 'Update 2',
        update_date: 1.day.ago,
        pdf_file: {
          io: tempfile2,
          filename: 'test2.pdf',
          content_type: 'application/pdf'
        }
      )
    ]

    tempfile1.close
    tempfile1.unlink
    tempfile2.close
    tempfile2.unlink

    updates
  end

  before do
    assign(:design_updates, design_updates)
    render
  end

  it 'displays all design updates' do
    expect(rendered).to include('Update 1')
    expect(rendered).to include('Update 2')
  end

  it 'has a new design update link' do
    expect(rendered).to have_link('New Design Update', href: new_admin_panel_design_update_path)
  end

  it 'displays PDF links' do
    expect(rendered).to have_link('View PDF')
  end

  it 'has edit links' do
    expect(rendered).to have_link('Edit')
  end

  it 'has delete buttons' do
    expect(rendered).to have_button('Delete')
  end
end
