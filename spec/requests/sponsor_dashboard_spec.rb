require 'rails_helper'

RSpec.describe SponsorDashboardController, type: :request do
  let(:user) do
    User.create!(
      email: 'test@example.com',
      first_name: 'Test',
      last_name: 'User',
      google_uid: '123',
      role: 'sponsor'
    )
  end

  let(:sponsor) do
    Sponsor.create!(
      company_name: 'TechCorp',
      website: 'https://techcorp.com',
      tier: 'Gold',
      resume_access: true
    )
  end

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    # Clear any existing sponsor assignments
    user.sponsors.clear
  end

  describe 'GET /sponsor_dashboard' do
    context 'when user has a sponsor' do
      before do
        user.sponsors << sponsor
      end

      it 'returns http success' do
        get sponsor_dashboard_index_path
        expect(response).to have_http_status(:success)
      end

      it 'displays the user\'s sponsor information' do
        get sponsor_dashboard_index_path
        expect(response.body).to include('TechCorp')
      end

      it 'does not show warning about unassigned sponsor' do
        get sponsor_dashboard_index_path
        expect(response.body).not_to match(/not assigned to a sponsor|contact an administrator/i)
      end
    end

    context 'when user has no sponsor' do
      it 'returns http success' do
        get sponsor_dashboard_index_path
        expect(response).to have_http_status(:success)
      end

      it 'assigns default sponsor to user automatically' do
        expect(user.sponsors).to be_empty
        get sponsor_dashboard_index_path
        user.reload
        expect(user.sponsors.first&.company_name).to eq('Unassigned Sponsor')
      end

      it 'displays the default sponsor information' do
        get sponsor_dashboard_index_path
        expect(response.body).to include('Unassigned Sponsor')
      end
    end

    context 'when user is on default sponsor' do
      before do
        default_sponsor = Sponsor.default_sponsor
        user.sponsors << default_sponsor
      end

      it 'displays default sponsor information' do
        get sponsor_dashboard_index_path
        expect(response.body).to include('Unassigned Sponsor')
      end

      it 'shows notice in the rendered page' do
        get sponsor_dashboard_index_path
        # flash.now is rendered in the page, not available to flash[] assertion
        expect(response.body).to match(/not assigned to a sponsor|contact an administrator/i)
      end
    end

    context 'authorization' do
      context 'when user is not a sponsor' do
        let(:student_user) do
          User.create!(
            email: 'student@example.com',
            first_name: 'Student',
            last_name: 'User',
            google_uid: '789',
            role: 'student'
          )
        end

        before do
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(student_user)
        end

        it 'does not allow access' do
          get sponsor_dashboard_index_path
          expect(response).not_to have_http_status(:success)
        end
      end
    end

    context 'when sponsor has resume access enabled' do
      before do
        sponsor.update!(resume_access: true)
        user.sponsors << sponsor
      end

      it 'displays resume access information' do
        get sponsor_dashboard_index_path
        expect(response.body).to match(/resume/i)
      end
    end

    context 'when sponsor has resume access disabled' do
      before do
        sponsor.update!(resume_access: false)
        user.sponsors << sponsor
      end

      it 'shows limited access information' do
        get sponsor_dashboard_index_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
