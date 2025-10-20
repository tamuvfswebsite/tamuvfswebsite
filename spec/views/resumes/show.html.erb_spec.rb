require 'rails_helper'

RSpec.describe 'resumes/show', type: :view do
  before do
    @user = User.create!(email: 'test@example.com', google_uid: '12345', first_name: 'Test', last_name: 'User')
    @resume = Resume.new(user: @user)
    @resume.file.attach(io: File.open(Rails.root.join('spec/fixtures/test.pdf')), filename: 'test.pdf',
                        content_type: 'application/pdf')
    @resume.save!
    assign(:user, @user)
    assign(:resume, @resume)
  end

  it 'renders the resume page' do
    render
    expect(rendered).to match(/Your Resume/)
    expect(rendered).to have_link('Download')
    expect(rendered).to have_link('Edit this resume')
    expect(rendered).to have_button('Delete Resume')
  end
end
