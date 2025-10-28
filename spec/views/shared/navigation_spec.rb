require 'rails_helper'

RSpec.describe 'shared/_navigation', type: :view do
  context 'when user is not signed in' do
    before do
      allow(view).to receive(:admin_signed_in?).and_return(false)
      allow(view).to receive(:admin_user?).and_return(false)
      render
    end

    it 'displays the navigation bar' do
      expect(rendered).to have_css('nav.navbar')
    end

    it 'has semantic HTML with proper ARIA labels' do
      expect(rendered).to have_css('nav[role="navigation"][aria-label="Main navigation"]')
    end

    it 'includes the brand logo link' do
      expect(rendered).to have_link('Home', href: root_path, class: 'navbar-logo')
    end

    it 'displays public navigation links' do
      expect(rendered).to have_link('Home', href: root_path)
      expect(rendered).to have_link('Events', href: events_path)
    end

    it 'displays sign in button for unauthenticated users' do
      expect(rendered).to have_button('Sign In')
      expect(rendered).to have_css('form[action="/admins/auth/google_oauth2"][method="post"]')
    end

    it 'does not display authenticated-only links' do
      expect(rendered).not_to have_link('Admin Panel')
      expect(rendered).not_to have_link('Sign Out')
      expect(rendered).not_to have_link('My Resume')
      expect(rendered).not_to have_link('Resumes')
      expect(rendered).not_to have_link('Apply for Role')
    end

    it 'includes mobile toggle button with accessibility attributes' do
      expect(rendered).to have_css('button.navbar-toggle[aria-label="Toggle navigation menu"][aria-expanded="false"][aria-controls="navbar-menu"]')
    end

    it 'has Stimulus controller data attributes' do
      expect(rendered).to have_css('nav[data-controller="navigation"]')
      expect(rendered).to have_css('button[data-navigation-target="toggle"]')
      expect(rendered).to have_css('div[data-navigation-target="menu"]')
    end
  end

  context 'when user is signed in as admin' do
    let(:admin_user) { User.create!(google_uid: 'admin123', email: 'admin@test.com', first_name: 'Admin', last_name: 'User', role: 'admin') }

    before do
      allow(view).to receive(:admin_signed_in?).and_return(true)
      allow(view).to receive(:admin_user?).and_return(true)
      allow(view).to receive(:current_user).and_return(admin_user)
      allow(view).to receive(:admin_panel_root_path).and_return('/admin_panel')
      allow(view).to receive(:destroy_admin_session_path).and_return('/admins/sign_out')
      render
    end

    it 'displays admin navigation links' do
      expect(rendered).to have_link('Admin Panel', href: '/admin_panel')
      expect(rendered).to have_link('Sign Out', href: '/admins/sign_out')
    end

    it 'displays all resumes link for admins' do
      expect(rendered).to have_link('Resumes', href: resumes_path)
      expect(rendered).not_to have_link('My Resume')
    end

    it 'does not display sign in button' do
      expect(rendered).not_to have_button('Sign In')
    end

    it 'still displays public navigation links' do
      expect(rendered).to have_link('Home', href: root_path)
      expect(rendered).to have_link('Events', href: events_path)
    end
  end

  context 'when user is signed in as regular user' do
    let(:regular_user) { User.create!(google_uid: 'user123', email: 'user@test.com', first_name: 'Regular', last_name: 'User', role: 'user') }

    before do
      allow(view).to receive(:admin_signed_in?).and_return(true)
      allow(view).to receive(:admin_user?).and_return(false)
      allow(view).to receive(:current_user).and_return(regular_user)
      allow(view).to receive(:user_resume_path).and_return("/users/#{regular_user.id}/resume")
      allow(view).to receive(:destroy_admin_session_path).and_return('/admins/sign_out')
      render
    end

    it 'displays my resume link for regular users' do
      expect(rendered).to have_link('My Resume', href: "/users/#{regular_user.id}/resume")
      expect(rendered).not_to have_link('Resumes')
    end

    it 'does not display admin panel link' do
      expect(rendered).not_to have_link('Admin Panel')
    end

    it 'displays sign out link' do
      expect(rendered).to have_link('Sign Out', href: '/admins/sign_out')
    end

    it 'displays public navigation links' do
      expect(rendered).to have_link('Home', href: root_path)
      expect(rendered).to have_link('Events', href: events_path)
      expect(rendered).to have_link('Apply for Role', href: new_role_application_path)
    end
  end

  context 'active page highlighting' do
    before do
      allow(view).to receive(:admin_signed_in?).and_return(false)
      allow(view).to receive(:admin_user?).and_return(false)
    end

    it 'marks the home link as active when on root path' do
      allow(view).to receive(:current_page?).with(root_path).and_return(true)
      allow(view).to receive(:current_page?).with(events_path).and_return(false)
      render

      expect(rendered).to have_css('a.nav-link.active', text: 'Home')
    end

    it 'marks the events link as active when on events path' do
      allow(view).to receive(:current_page?).with(root_path).and_return(false)
      allow(view).to receive(:current_page?).with(events_path).and_return(true)
      render

      expect(rendered).to have_css('a.nav-link.active', text: 'Events')
    end
  end

  context 'keyboard navigation' do
    before do
      allow(view).to receive(:admin_signed_in?).and_return(false)
      allow(view).to receive(:admin_user?).and_return(false)
      render
    end

    it 'all navigation links are keyboard accessible' do
      # Check that links exist (when not signed in: Home, Events, plus brand logo)
      expect(rendered).to have_css('a.nav-link', minimum: 2)
    end

    it 'toggle button is accessible via keyboard' do
      expect(rendered).to have_css('button.navbar-toggle[type="button"]')
    end
  end
end
