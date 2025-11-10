require 'rails_helper'

RSpec.describe 'Navigation Integration', type: :request do
  describe 'Navigation bar presence across pages' do
    context 'on public pages' do
      it 'displays navigation on root path' do
        get root_path
        expect(response.body).to include('class="navbar"')
        expect(response.body).to include('Main navigation')
      end

      it 'displays navigation on events index' do
        get events_path
        expect(response.body).to include('class="navbar"')
        expect(response.body).to include('Main navigation')
      end
    end

    context 'on authenticated pages for regular users' do
      let(:user) { create_user(role: 'user') }

      before do
        sign_in_as_admin(user)
      end

      it 'displays navigation on homepage' do
        get root_path
        expect(response.body).to include('class="navbar"')
        expect(response.body).to include('Main navigation')
      end

      it 'includes navigation links for regular users' do
        get root_path
        expect(response.body).to include('Home')
        expect(response.body).to include('Events')
        expect(response.body).to include('My Resume')
        expect(response.body).to include('My Applications')
      end

      it 'does not show admin panel to regular users' do
        get root_path
        expect(response.body).not_to include('Admin Panel')
      end
    end

    context 'for admin users' do
      let(:admin_user) { create_user(role: 'admin') }

      before do
        sign_in_as_admin(admin_user)
      end

      it 'displays admin-specific links' do
        get root_path
        expect(response.body).to include('Admin Panel')
        expect(response.body).to include('Sign Out')
      end

      it 'displays all resumes link for admins' do
        get root_path
        expect(response.body).to include('Resumes')
        expect(response.body).not_to include('My Resume')
      end

      it 'displays navigation on admin panel pages' do
        allow_any_instance_of(AdminPanel::DashboardController).to receive(:ensure_admin_user).and_return(true)

        get admin_panel_dashboard_path
        expect(response.body).to include('class="navbar"')
      end
    end
  end

  describe 'Active page highlighting' do
    let(:user) { create_user(role: 'user') }

    before do
      sign_in_as_admin(user)
    end

    it 'marks current page as active on root path' do
      get root_path
      expect(response.body).to match(%r{<a[^>]*class="[^"]*nav-link[^"]*active[^"]*"[^>]*>Home</a>})
    end

    it 'marks events page as active when on events index' do
      get events_path
      expect(response.body).to match(%r{<a[^>]*class="[^"]*nav-link[^"]*active[^"]*"[^>]*>Events</a>})
    end
  end

  describe 'Navigation functionality' do
    it 'has proper semantic HTML structure' do
      get root_path
      expect(response.body).to include('<nav')
      expect(response.body).to include('role="navigation"')
      expect(response.body).to include('aria-label="Main navigation"')
    end

    it 'includes Stimulus controller for interactivity' do
      get root_path
      expect(response.body).to include('data-controller="navigation"')
    end

    it 'has mobile menu toggle button' do
      get root_path
      expect(response.body).to include('class="navbar-toggle"')
      expect(response.body).to include('aria-label="Toggle navigation menu"')
    end

    it 'has keyboard accessible elements' do
      get root_path
      expect(response.body).to include('aria-expanded')
      expect(response.body).to include('aria-controls')
    end
  end

  describe 'Responsive design' do
    it 'includes navbar container for proper layout' do
      get root_path
      expect(response.body).to include('class="navbar-container"')
    end

    it 'includes navbar menu for mobile responsiveness' do
      get root_path
      expect(response.body).to include('class="navbar-menu"')
      expect(response.body).to include('id="navbar-menu"')
    end
  end

  describe 'Authentication state reflection' do
    context 'when not signed in' do
      it 'shows sign in button' do
        get root_path
        expect(response.body).to include('Sign In')
        expect(response.body).to include('/admins/auth/google_oauth2')
        expect(response.body).not_to include('Sign Out')
      end

      it 'does not show admin panel link' do
        get root_path
        expect(response.body).not_to include('Admin Panel')
      end

      it 'does not show resume links' do
        get root_path
        expect(response.body).not_to include('My Resume')
        expect(response.body).not_to include('Resumes')
      end
    end

    context 'when signed in as regular user' do
      let(:user) { create_user(role: 'user') }

      before do
        sign_in_as_admin(user)
      end

      it 'shows sign out link' do
        get root_path
        expect(response.body).to include('Sign Out')
        expect(response.body).not_to include('Sign In')
      end

      it 'shows my resume link' do
        get root_path
        expect(response.body).to include('My Resume')
        expect(response.body).not_to include('Resumes')
      end

      it 'does not show admin panel link' do
        get root_path
        expect(response.body).not_to include('Admin Panel')
      end
    end

    context 'when signed in as admin' do
      let(:admin_user) { create_user(role: 'admin') }

      before do
        sign_in_as_admin(admin_user)
      end

      it 'shows admin panel link' do
        get root_path
        expect(response.body).to include('Admin Panel')
      end

      it 'shows all resumes link' do
        get root_path
        expect(response.body).to include('Resumes')
        expect(response.body).not_to include('My Resume')
      end
    end
  end
end
