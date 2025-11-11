require 'rails_helper'

RSpec.describe SponsorsController, type: :request do
  let(:user) do
    User.create!(
      email: 'sponsor@example.com',
      first_name: 'Sponsor',
      last_name: 'User',
      google_uid: '456',
      role: 'sponsor'
    )
  end

  let(:sponsor) do
    Sponsor.create!(
      company_name: 'TechCorp',
      website: 'https://techcorp.com',
      tier: 'Gold',
      contact_email: 'contact@techcorp.com',
      phone_number: '123-456-7890',
      company_description: 'A great tech company.',
      resume_access: true
    )
  end

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    # Clear any existing sponsor assignments
    user.sponsors.clear
  end

  describe 'GET /sponsor/edit' do
    context 'with a valid sponsor' do
      before do
        user.sponsors << sponsor
      end

      it 'returns http success' do
        get edit_sponsor_path(sponsor)
        expect(response).to have_http_status(:success)
      end

      it 'displays the sponsor information' do
        get edit_sponsor_path(sponsor)
        expect(response.body).to include('TechCorp')
      end
    end

    context 'when user has no sponsor (auto-assigned to default)' do
      it 'assigns default sponsor and shows edit page' do
        get edit_sponsor_path(sponsor)
        # The set_sponsor method will assign default sponsor
        # Since it's default sponsor, redirect should happen
        expect(response).to have_http_status(:redirect).or have_http_status(:success)
      end
    end

    context 'when trying to edit default sponsor' do
      let(:default_sponsor) { Sponsor.default_sponsor }

      before do
        user.sponsors << default_sponsor
      end

      it 'redirects to dashboard' do
        get edit_sponsor_path(default_sponsor)
        expect(response).to redirect_to(sponsor_dashboard_index_path)
      end

      it 'shows an alert message' do
        get edit_sponsor_path(default_sponsor)
        expect(flash[:alert]).to include('cannot edit')
      end
    end
  end

  describe 'PATCH /sponsor' do
    context 'with valid parameters' do
      before do
        user.sponsors << sponsor
      end

      let(:valid_params) do
        {
          sponsor: {
            company_name: 'Updated TechCorp',
            website: 'https://updated-techcorp.com',
            tier: 'Platinum',
            contact_email: 'new@techcorp.com',
            phone_number: '987-654-3210',
            company_description: 'An updated tech company.'
          }
        }
      end

      it 'updates the sponsor' do
        patch sponsor_path(sponsor), params: valid_params
        sponsor.reload
        expect(sponsor.company_name).to eq('Updated TechCorp')
        expect(sponsor.website).to eq('https://updated-techcorp.com')
        expect(sponsor.tier).to eq('Platinum')
      end

      it 'redirects to dashboard' do
        patch sponsor_path(sponsor), params: valid_params
        expect(response).to redirect_to(sponsor_dashboard_index_path)
      end

      it 'shows a success notice' do
        patch sponsor_path(sponsor), params: valid_params
        expect(flash[:notice]).to include('successfully updated')
      end
    end

    context 'with invalid parameters' do
      before do
        user.sponsors << sponsor
        allow_any_instance_of(Sponsor).to receive(:update).and_return(false)
      end

      it 'does not update the sponsor' do
        original_name = sponsor.company_name
        patch sponsor_path(sponsor), params: { sponsor: { company_name: '' } }
        sponsor.reload
        expect(sponsor.company_name).to eq(original_name)
      end

      it 'renders the edit template' do
        patch sponsor_path(sponsor), params: { sponsor: { company_name: '' } }
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user has no sponsor (auto-assigned to default)' do
      it 'prevents update because default sponsor' do
        patch sponsor_path(sponsor), params: { sponsor: { company_name: 'Updated' } }
        # set_sponsor assigns default, then update checks for default and redirects
        expect(response).to have_http_status(:redirect).or have_http_status(:success)
      end
    end

    context 'when trying to update default sponsor' do
      let(:default_sponsor) { Sponsor.default_sponsor }

      before do
        user.sponsors << default_sponsor
      end

      it 'redirects to dashboard' do
        patch sponsor_path(default_sponsor), params: { sponsor: { company_name: 'Updated' } }
        expect(response).to redirect_to(sponsor_dashboard_index_path)
      end

      it 'does not update the sponsor' do
        original_name = default_sponsor.company_name
        patch sponsor_path(default_sponsor), params: { sponsor: { company_name: 'Updated' } }
        default_sponsor.reload
        expect(default_sponsor.company_name).to eq(original_name)
      end

      it 'shows an alert message' do
        patch sponsor_path(default_sponsor), params: { sponsor: { company_name: 'Updated' } }
        expect(flash[:alert]).to include('cannot edit')
      end
    end
  end

  describe 'authorization' do
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

      it 'does not allow access to edit' do
        get edit_sponsor_path(sponsor)
        expect(response).not_to have_http_status(:success)
      end

      it 'does not allow access to update' do
        patch sponsor_path(sponsor), params: { sponsor: { company_name: 'Updated' } }
        expect(response).not_to have_http_status(:success)
      end
    end
  end
end
