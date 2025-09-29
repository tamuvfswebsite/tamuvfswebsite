require 'rails_helper'

RSpec.describe 'resumes/new', type: :view do
  before(:each) do
    @user = User.create!(email: 'test@example.com', google_uid: '12345')
    assign(:user, @user)
    assign(:resume, Resume.new(user: @user))
  end

  it 'renders new resume form' do
    render

    assert_select 'form[action=?][method=?]', user_resume_path(@user), 'post' do
      assert_select 'input[type=?]', 'file'
    end
  end
end
