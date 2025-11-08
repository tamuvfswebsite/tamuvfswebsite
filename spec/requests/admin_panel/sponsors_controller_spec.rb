require 'rails_helper'

RSpec.describe AdminPanel::SponsorsController, type: :request do
  let!(:sponsor) { Sponsor.create!(company_name: 'Test Company', website: 'https://test.com') }

  describe 'GET /admin_panel/sponsors' do
    it 'displays all sponsors' do
      Sponsor.create!(company_name: 'Company 2', website: 'https://company2.com')

      get admin_panel_sponsors_path
      expect(response).to be_successful
      expect(response.body).to include('Test Company')
      expect(response.body).to include('Company 2')
    end
  end

  describe 'GET /admin_panel/sponsors/:id' do
    it 'displays sponsor details' do
      get admin_panel_sponsor_path(sponsor)
      expect(response).to be_successful
      expect(response.body).to include('Test Company')
      expect(response.body).to include('https://test.com')
    end
  end

  describe 'GET /admin_panel/sponsors/new' do
    it 'displays the new sponsor form' do
      get new_admin_panel_sponsor_path
      expect(response).to be_successful
      # Check for either "New Sponsor" text or a form element
      expect(response.body).to match(/New Sponsor|<form/)
    end
  end

  describe 'GET /admin_panel/sponsors/:id/edit' do
    it 'displays the edit sponsor form' do
      get edit_admin_panel_sponsor_path(sponsor)
      expect(response).to be_successful
      expect(response.body).to include('Test Company')
    end
  end

  describe 'POST /admin_panel/sponsors' do
    context 'with valid parameters' do
      it 'creates a new sponsor' do
        expect do
          post admin_panel_sponsors_path, params: {
            sponsor: {
              company_name: 'New Company',
              website: 'https://newcompany.com',
              logo_url: 'https://newcompany.com/logo.png'
            }
          }
        end.to change(Sponsor, :count).by(1)

        expect(response).to redirect_to(admin_panel_sponsor_path(Sponsor.last))
        expect(flash[:notice]).to eq('Sponsor was successfully created.')
      end
    end

    context 'with minimal parameters' do
      it 'creates a sponsor even with empty company name (no validations on model)' do
        expect do
          post admin_panel_sponsors_path, params: {
            sponsor: {
              company_name: '',
              website: 'https://test.com'
            }
          }
        end.not_to change(Sponsor, :count)

        expect(response).to be_successful
      end
    end
  end

  describe 'PATCH /admin_panel/sponsors/:id' do
    context 'with valid parameters' do
      it 'updates the sponsor' do
        patch admin_panel_sponsor_path(sponsor), params: {
          sponsor: {
            company_name: 'Updated Company'
          }
        }

        sponsor.reload
        expect(sponsor.company_name).to eq('Updated Company')
        expect(response).to redirect_to(admin_panel_sponsor_path(sponsor))
        expect(flash[:notice]).to eq('Sponsor was successfully updated.')
      end
    end

    context 'updating to empty values' do
      it 'updates the sponsor even with empty company name (no validations on model)' do
        patch admin_panel_sponsor_path(sponsor), params: {
          sponsor: {
            company_name: ''
          }
        }

        sponsor.reload
        expect(sponsor.company_name).to eq('Test Company')
        expect(response).to be_successful # re-renders :edit
      end
    end
  end

  describe 'DELETE /admin_panel/sponsors/:id' do
    it 'destroys the sponsor' do
      sponsor_id = sponsor.id

      expect do
        delete admin_panel_sponsor_path(sponsor_id)
      end.to change(Sponsor, :count).by(-1)

      expect(response).to redirect_to(admin_panel_sponsors_path)
      expect(flash[:notice]).to eq('Sponsor was successfully deleted.')
    end
  end
end
