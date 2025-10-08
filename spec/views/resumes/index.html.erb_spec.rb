require 'rails_helper'

RSpec.describe 'resumes/index', type: :view do
  before(:each) do
    @user1 = User.create!(email: 'test1@example.com', google_uid: '12345')
    @user2 = User.create!(email: 'test2@example.com', google_uid: '67890')
    resumes = []
    [@user1, @user2].each do |user|
      resume = Resume.new(user: user)
      resume.file.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'test.pdf')), filename: 'test.pdf',
                         content_type: 'application/pdf')
      resume.save!
      resumes << resume
    end
    # Provide a paginated collection so the view's `paginate` helper works in tests
    assign(:resumes, Kaminari.paginate_array(resumes).page(1).per(25))
  end

  it 'renders a list of resumes' do
    render
    assert_select 'table#resumes' do
      assert_select 'tbody tr', count: 2
      assert_select 'a', text: 'Show', count: 2
    end
  end
end
