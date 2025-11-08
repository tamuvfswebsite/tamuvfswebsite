require 'rails_helper'

RSpec.describe 'admin_panel/dashboard/index.html.erb', type: :view do
  context 'sunny day' do
    before do
      # Assign instance variables
      assign(:total_users, 42)
      assign(:total_events, 10)
      assign(:resume_count, 7)

      recent_event1 = double('Event', title: 'Tech Talk')
      recent_event2 = double('Event', title: 'Career Fair')
      assign(:recent_events, [recent_event1, recent_event2])

      # Assign sponsor download stats
      sponsor_stat1 = double('SponsorStat', first_name: 'John', last_name: 'Doe', email: 'john@sponsor.com',
                                            download_count: 5)
      sponsor_stat2 = double('SponsorStat', first_name: 'Jane', last_name: 'Smith', email: 'jane@sponsor.com',
                                            download_count: 3)
      assign(:sponsor_download_stats, [sponsor_stat1, sponsor_stat2])

      # Stub helper methods
      allow(view).to receive(:admin_signed_in?).and_return(true)
      allow(view).to receive(:current_admin).and_return(double('Admin', full_name: 'Alice Admin',
                                                                        email: 'alice@example.com'))

      render
    end

    it 'displays system overview counts' do
      expect(rendered).to include('Total Users: 42')
      expect(rendered).to include('Total Events: 10')
      expect(rendered).to include('Resume Count: 7')
    end

    it 'lists recent events' do
      expect(rendered).to include('Tech Talk')
      expect(rendered).to include('Career Fair')
    end

    it 'shows admin info when signed in' do
      expect(rendered).to include('Status: Logged in as admin')
      expect(rendered).to include('Name: Alice Admin')
      expect(rendered).to include('Email: alice@example.com')
    end

    it 'renders quick action links' do
      expect(rendered).to include('Manage Users')
      expect(rendered).to include('Manage Events')
      expect(rendered).to include('Manage Sponsors')
      expect(rendered).to include('View Resumes')
    end

    it 'displays sponsor download statistics' do
      expect(rendered).to include('Sponsor Download Statistics')
      expect(rendered).to include('John Doe')
      expect(rendered).to include('john@sponsor.com')
      expect(rendered).to include('Jane Smith')
      expect(rendered).to include('jane@sponsor.com')
    end
  end

  context 'rainy day' do
    before do
      # Assign instance variables
      assign(:total_users, 0)
      assign(:total_events, 0)
      assign(:resume_count, 0)
      assign(:recent_events, []) # no recent events
      assign(:sponsor_download_stats, []) # no sponsor downloads

      # Stub helper methods for admin not signed in
      allow(view).to receive(:admin_signed_in?).and_return(false)
      allow(view).to receive(:current_admin).and_return(nil)

      render
    end

    it 'shows system overview with zeros' do
      expect(rendered).to include('Total Users: 0')
      expect(rendered).to include('Total Events: 0')
      expect(rendered).to include('Resume Count: 0')
    end

    it 'shows message when no recent events' do
      expect(rendered).to include('No recent events found.')
    end

    it 'shows admin info when not signed in' do
      expect(rendered).to include('Status: Not logged in')
    end

    it 'shows message when no sponsor downloads' do
      expect(rendered).to include('No sponsor downloads recorded yet.')
    end
  end
end
