require 'rails_helper'

RSpec.describe 'resumes/show', type: :view do
  before(:each) do
    @user = User.create!(email: 'test@example.com', google_uid: '12345')
    @resume = Resume.new(user: @user)
    @resume.file.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'test.pdf')), filename: 'test.pdf',
                        content_type: 'application/pdf')
    @resume.save!
    assign(:user, @user)
    assign(:resume, @resume)
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/#{@user.email}/)
  end
end
