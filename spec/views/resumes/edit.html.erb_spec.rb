require 'rails_helper'

RSpec.describe 'resumes/edit', type: :view do
  before(:each) do
    @user = User.create!(email: 'test@example.com', google_uid: '12345')
    @resume = Resume.new(user: @user)
    @resume.file.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'test.pdf')), filename: 'test.pdf', content_type: 'application/pdf')
    @resume.save!
    assign(:user, @user)
    assign(:resume, @resume)
  end

  it 'renders the edit resume form' do
    render

    assert_select 'form[action=?][method=?]', user_resume_path(@user), 'post' do
      assert_select 'input[type=?]', 'file'
    end
  end
end
