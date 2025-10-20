require 'rails_helper'

RSpec.describe 'resumes/index', type: :view do
  let(:admin_user) { create_user(role: 'admin') }
  let(:admin) do
    Admin.create!(
      email: admin_user.email,
      uid: admin_user.google_uid,
      full_name: "#{admin_user.first_name} #{admin_user.last_name}"
    )
  end

  before do
    # Stub the Devise helper methods for views
    allow(view).to receive(:admin_signed_in?).and_return(true)
    allow(view).to receive(:current_admin).and_return(admin)

    @user1 = User.create!(email: 'test1@example.com', google_uid: '12345')
    @user2 = User.create!(email: 'test2@example.com', google_uid: '67890')
    resumes = []
    [@user1, @user2].each do |user|
      resume = Resume.new(user: user)
      resume.file.attach(io: File.open(Rails.root.join('spec/fixtures/test.pdf')), filename: 'test.pdf',
                         content_type: 'application/pdf')
      resume.save!
      resumes << resume
    end
    # Provide a paginated collection so the view's `paginate` helper works in tests
    assign(:resumes, Kaminari.paginate_array(resumes).page(1).per(25))

    # Assign filter options that the view expects
    assign(:majors, [])
    assign(:organizational_roles, [])
    assign(:graduation_years, [])
  end

  it 'renders a list of resumes' do
    render
    assert_select 'table#resumes' do
      assert_select 'tbody tr', count: 2
      assert_select 'a', text: 'Show', count: 2
    end
  end
end
