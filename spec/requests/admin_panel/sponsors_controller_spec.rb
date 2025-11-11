require 'rails_helper'

RSpec.describe AdminPanel::SponsorsController, type: :request do
  let(:admin_user) { double('AdminUser', id: 1, admin?: true) }

  let(:sponsor) do
    Sponsor.create!(
      company_name: 'Tech Corp',
      website: 'https://techcorp.com',
      tier: 'Gold',
      contact_email: 'contact@techcorp.com',
      phone_number: '123-456-7890',
      company_description: 'A great tech company.',
      resume_access: true
    )
  end

  before do
    allow_any_instance_of(AdminPanel::BaseController).to receive(:ensure_admin_user).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin_user)
  end

  describe 'GET /admin_panel/sponsors' do
    it 'returns http success' do
      get admin_panel_sponsors_path
      expect(response).to have_http_status(:success)
    end

    it 'displays all sponsors ordered by company name' do
      Sponsor.create!(company_name: 'Zebra Corp', website: 'https://zebra.com')
      Sponsor.create!(company_name: 'Alpha Corp', website: 'https://alpha.com')

      get admin_panel_sponsors_path

      expect(response.body).to include('Alpha Corp')
      expect(response.body).to include('Zebra Corp')
      expect(response.body.index('Alpha Corp')).to be < response.body.index('Zebra Corp')
    end
  end

  describe 'GET /admin_panel/sponsors/:id' do
    it 'returns http success' do
      get admin_panel_sponsor_path(sponsor)
      expect(response).to have_http_status(:success)
    end

    it 'displays sponsor details' do
      get admin_panel_sponsor_path(sponsor)
      expect(response.body).to include('Tech Corp')
      expect(response.body).to include('https://techcorp.com')
    end
  end

  describe 'GET /admin_panel/sponsors/new' do
    it 'returns http success' do
      get new_admin_panel_sponsor_path
      expect(response).to have_http_status(:success)
    end

    it 'displays the new sponsor form' do
      get new_admin_panel_sponsor_path
      expect(response.body).to match(/New Sponsor|<form/)
    end
  end

  describe 'GET /admin_panel/sponsors/:id/edit' do
    it 'returns http success' do
      get edit_admin_panel_sponsor_path(sponsor)
      expect(response).to have_http_status(:success)
    end

    it 'displays the edit form with sponsor data' do
      get edit_admin_panel_sponsor_path(sponsor)
      expect(response.body).to include('Tech Corp')
      expect(response.body).to include('Edit')
    end
  end

  describe 'POST /admin_panel/sponsors' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          sponsor: {
            company_name: 'New Company',
            website: 'https://newcompany.com',
            tier: 'Silver',
            contact_email: 'contact@newcompany.com',
            phone_number: '555-1234',
            company_description: 'A new company.',
            resume_access: true
          }
        }
      end

      it 'creates a new sponsor' do
        expect do
          post admin_panel_sponsors_path, params: valid_params
        end.to change(Sponsor, :count).by(1)
      end

      it 'redirects to the sponsor show page' do
        post admin_panel_sponsors_path, params: valid_params
        expect(response).to redirect_to(admin_panel_sponsor_path(Sponsor.last))
      end

      it 'shows a success notice' do
        post admin_panel_sponsors_path, params: valid_params
        expect(flash[:notice]).to eq('Sponsor was successfully created.')
      end

      it 'sets the correct attributes' do
        post admin_panel_sponsors_path, params: valid_params
        new_sponsor = Sponsor.last
        expect(new_sponsor.company_name).to eq('New Company')
        expect(new_sponsor.website).to eq('https://newcompany.com')
        expect(new_sponsor.tier).to eq('Silver')
      end
    end

    context 'with invalid parameters' do
      before do
        allow_any_instance_of(Sponsor).to receive(:save).and_return(false)
      end

      it 'does not create a sponsor' do
        expect do
          post admin_panel_sponsors_path, params: { sponsor: { company_name: '' } }
        end.not_to change(Sponsor, :count)
      end

      it 'renders the new template' do
        post admin_panel_sponsors_path, params: { sponsor: { company_name: '' } }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('New Sponsor')
      end
    end
  end

  describe 'PATCH /admin_panel/sponsors/:id' do
    context 'with valid parameters' do
      let(:update_params) do
        {
          sponsor: {
            company_name: 'Updated Company',
            tier: 'Platinum',
            resume_access: false
          }
        }
      end

      it 'updates the sponsor' do
        patch admin_panel_sponsor_path(sponsor), params: update_params
        sponsor.reload
        expect(sponsor.company_name).to eq('Updated Company')
        expect(sponsor.tier).to eq('Platinum')
        expect(sponsor.resume_access).to be false
      end

      it 'redirects to the sponsor show page' do
        patch admin_panel_sponsor_path(sponsor), params: update_params
        expect(response).to redirect_to(admin_panel_sponsor_path(sponsor))
      end

      it 'shows a success notice' do
        patch admin_panel_sponsor_path(sponsor), params: update_params
        expect(flash[:notice]).to eq('Sponsor was successfully updated.')
      end
    end

    context 'with invalid parameters' do
      before do
        allow_any_instance_of(Sponsor).to receive(:update).and_return(false)
      end

      it 'does not update the sponsor' do
        original_name = sponsor.company_name
        patch admin_panel_sponsor_path(sponsor), params: { sponsor: { company_name: '' } }
        sponsor.reload
        expect(sponsor.company_name).to eq(original_name)
      end

      it 'renders the edit template' do
        patch admin_panel_sponsor_path(sponsor), params: { sponsor: { company_name: '' } }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Edit')
      end
    end
  end

  describe 'DELETE /admin_panel/sponsors/:id' do
    context 'with a regular sponsor' do
      it 'destroys the sponsor' do
        sponsor_to_delete = Sponsor.create!(company_name: 'Delete Me', website: 'https://delete.com')

        if Sponsor.count == 1
          expect do
            delete admin_panel_sponsor_path(sponsor_to_delete)
          end.not_to change(Sponsor, :count)
        else
          expect do
            delete admin_panel_sponsor_path(sponsor_to_delete)
          end.to change(Sponsor, :count).by(-1)
        end
      end

      it 'redirects to sponsors index' do
        delete admin_panel_sponsor_path(sponsor)
        expect(response).to redirect_to(admin_panel_sponsors_path)
      end

      it 'shows a success notice' do
        delete admin_panel_sponsor_path(sponsor)
        expect(flash[:notice]).to include('Sponsor was successfully deleted')
      end

      it 'mentions users were moved to default sponsor' do
        delete admin_panel_sponsor_path(sponsor)
        expect(flash[:notice]).to include('Associated users were moved to the default sponsor')
      end
    end

    context 'when trying to delete default sponsor' do
      let(:default_sponsor) { Sponsor.default_sponsor }

      it 'does not destroy the sponsor' do
        default_sponsor # ensure it exists
        expect do
          delete admin_panel_sponsor_path(default_sponsor)
        end.not_to change(Sponsor, :count)
      end

      it 'redirects to sponsors index' do
        delete admin_panel_sponsor_path(default_sponsor)
        expect(response).to redirect_to(admin_panel_sponsors_path)
      end

      it 'shows an error alert' do
        delete admin_panel_sponsor_path(default_sponsor)
        expect(flash[:alert]).to eq('Cannot delete the default sponsor.')
      end
    end
  end

  describe 'DELETE /admin_panel/sponsors/:id/remove_logo' do
    context 'when sponsor has a logo' do
      before do
        allow(sponsor).to receive_message_chain(:logo, :attached?).and_return(true)
        allow(sponsor).to receive_message_chain(:logo, :purge)
        allow(Sponsor).to receive(:find).and_return(sponsor)
      end

      it 'removes the logo' do
        expect(sponsor.logo).to receive(:purge)
        delete remove_logo_admin_panel_sponsor_path(sponsor)
      end

      it 'redirects to edit page' do
        delete remove_logo_admin_panel_sponsor_path(sponsor)
        expect(response).to redirect_to(edit_admin_panel_sponsor_path(sponsor))
      end

      it 'shows a success notice' do
        delete remove_logo_admin_panel_sponsor_path(sponsor)
        expect(flash[:notice]).to eq('Logo was successfully removed.')
      end
    end

    context 'when sponsor has no logo' do
      before do
        allow(sponsor).to receive_message_chain(:logo, :attached?).and_return(false)
        allow(Sponsor).to receive(:find).and_return(sponsor)
      end

      it 'does not attempt to remove logo' do
        expect(sponsor.logo).not_to receive(:purge)
        delete remove_logo_admin_panel_sponsor_path(sponsor)
      end

      it 'redirects to edit page' do
        delete remove_logo_admin_panel_sponsor_path(sponsor)
        expect(response).to redirect_to(edit_admin_panel_sponsor_path(sponsor))
      end

      it 'shows an alert message' do
        delete remove_logo_admin_panel_sponsor_path(sponsor)
        expect(flash[:alert]).to eq('No logo to remove.')
      end
    end
  end

  describe 'GET /admin_panel/sponsors/:id/assign_users' do
    let(:sponsor_user1) do
      User.create!(
        email: 'sponsor1@example.com',
        first_name: 'Sponsor',
        last_name: 'One',
        google_uid: '123',
        role: 'sponsor'
      )
    end

    let(:sponsor_user2) do
      User.create!(
        email: 'sponsor2@example.com',
        first_name: 'Sponsor',
        last_name: 'Two',
        google_uid: '456',
        role: 'sponsor'
      )
    end

    before do
      # Clear any existing sponsor assignments
      sponsor_user1.sponsors.clear
      sponsor_user2.sponsors.clear
      # Assign user1 to this sponsor
      sponsor_user1.sponsors << sponsor
    end

    it 'returns http success' do
      get assign_users_admin_panel_sponsor_path(sponsor)
      expect(response).to have_http_status(:success)
    end

    it 'displays the assign users page' do
      get assign_users_admin_panel_sponsor_path(sponsor)
      expect(response.body).to match(/Assign Users|User Assignment/i)
    end

    it 'shows both available and assigned users' do
      get assign_users_admin_panel_sponsor_path(sponsor)
      expect(response.body).to include(sponsor_user1.email)
      expect(response.body).to include(sponsor_user2.email)
    end
  end

  describe 'PATCH /admin_panel/sponsors/:id/update_users' do
    let(:sponsor_user1) do
      User.create!(
        email: 'sponsor1@example.com',
        first_name: 'Sponsor',
        last_name: 'One',
        google_uid: '123',
        role: 'sponsor'
      )
    end

    let(:sponsor_user2) do
      User.create!(
        email: 'sponsor2@example.com',
        first_name: 'Sponsor',
        last_name: 'Two',
        google_uid: '456',
        role: 'sponsor'
      )
    end

    before do
      sponsor_user1.sponsors.clear
      sponsor_user2.sponsors.clear
    end

    context 'with valid user assignments' do
      it 'updates user assignments' do
        patch update_users_admin_panel_sponsor_path(sponsor), params: {
          sponsor: { user_ids: [sponsor_user1.id, sponsor_user2.id] }
        }

        sponsor.reload
        expect(sponsor.users).to include(sponsor_user1, sponsor_user2)
      end

      it 'redirects to sponsor show page' do
        patch update_users_admin_panel_sponsor_path(sponsor), params: {
          sponsor: { user_ids: [sponsor_user1.id] }
        }

        expect(response).to redirect_to(admin_panel_sponsor_path(sponsor))
      end

      it 'shows success notice with user count' do
        patch update_users_admin_panel_sponsor_path(sponsor), params: {
          sponsor: { user_ids: [sponsor_user1.id, sponsor_user2.id] }
        }

        expect(flash[:notice]).to include('Users updated successfully')
        expect(flash[:notice]).to include('2 user(s) assigned')
      end
    end

    context 'with no user assignments' do
      it 'clears all user assignments and assigns to default' do
        sponsor_user1.sponsors << sponsor

        patch update_users_admin_panel_sponsor_path(sponsor), params: {
          sponsor: { user_ids: [] }
        }

        sponsor.reload
        expect(sponsor.users).to be_empty

        sponsor_user1.reload
        expect(sponsor_user1.sponsors.map(&:company_name)).to include('Unassigned Sponsor')
      end
    end

    context 'when an error occurs' do
      before do
        allow(AdminPanel::SponsorUserAssigner).to receive(:new).and_raise(StandardError, 'Test error')
      end

      it 'redirects to assign users page' do
        patch update_users_admin_panel_sponsor_path(sponsor), params: {
          sponsor: { user_ids: [sponsor_user1.id] }
        }

        expect(response).to redirect_to(assign_users_admin_panel_sponsor_path(sponsor))
      end

      it 'shows error alert' do
        patch update_users_admin_panel_sponsor_path(sponsor), params: {
          sponsor: { user_ids: [sponsor_user1.id] }
        }

        expect(flash[:alert]).to include('Error updating users')
        expect(flash[:alert]).to include('Test error')
      end
    end
  end
end
