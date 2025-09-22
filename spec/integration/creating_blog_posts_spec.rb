# require 'rails_helper'
#
# RSpec.describe "CreatingBlogPosts", type: :system do
#   before do
#     driven_by(:rack_test)
#   end
#
# #  pending "add some scenarios (or delete) #{__FILE__}"
# it 'saves & displays the resulting blog post' do
#   visit root_path
#   expect(page).to have_current_path(root_path)
#   expect(page).to have_link("New Post", wait: 10)
#   click_on "New Post"
#
#   fill_in 'Title', with: 'Hello, World!'
#   fill_in 'Body', with: 'Hello, I say!'
#
#   click_on 'Create Post'
#
#   expect(page).to have_content('Hello, World!')
#   expect(page).to have_content('Hello, I say!')
#
#   post = Post.order("id").last
#   expect(post.title).to eq('Hello, World!')
#   expect(post.body).to eq('Hello, I say!')
# end
#
#
# end

# new tests to make test work with OmniAuth
require 'rails_helper'

RSpec.describe "CreatingBlogPosts", type: :system do
  before do
    driven_by(:rack_test)

    # Configure OmniAuth for testing
    OmniAuth.config.test_mode = true

    # Mock the Google OAuth response
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: 'google_oauth2',
      uid: '123456',
      info: {
        email: 'admin@example.com',
        name: 'Admin User',
        image: 'https://example.com/avatar.jpg'
      },
      credentials: {
        token: 'mock_token',
        expires_at: Time.now + 1.week
      }
    })

    # Create an admin in the database
    @admin = Admin.create!(
      email: 'admin@example.com',
      full_name: 'Admin User',
      uid: '123456',
      avatar_url: 'https://example.com/avatar.jpg'
    )
  end

  it 'saves & displays the resulting blog post' do
    # Simulate OAuth login
    #visit '/admins/auth/google_oauth2/callback'
    visit new_admin_session_path
    click_on "Google"
    # Expect to be redirected to the root path after successful login
    expect(page).to have_current_path(root_path)

    expect(page).to have_link("New Post", wait: 10)
    click_on "New Post"

    fill_in 'Title', with: 'Hello, World!'
    fill_in 'Body', with: 'Hello, I say!'

    click_on 'Create Post'

    expect(page).to have_content('Hello, World!')
    expect(page).to have_content('Hello, I say!')

    post = Post.order("id").last
    expect(post.title).to eq('Hello, World!')
    expect(post.body).to eq('Hello, I say!')
  end
end
