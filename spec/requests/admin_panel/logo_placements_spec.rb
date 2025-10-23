require 'rails_helper'

RSpec.describe '/admin_panel/sponsors/:sponsor_id/logo_placements', type: :request do
  let(:sponsor) do
    Sponsor.create!(
      company_name: 'Test Company',
      website: 'https://example.com',
      logo_url: 'https://example.com/logo.png',
      resume_access: false
    )
  end

  let(:valid_attributes) do
    {
      page_name: 'home',
      section: 'header',
      displayed: true,
      sponsor_id: sponsor.id
    }
  end

  let(:invalid_attributes) do
    {
      page_name: '',
      section: '',
      displayed: nil,
      sponsor_id: nil
    }
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      logo_placement = sponsor.logo_placements.create! valid_attributes
      get admin_panel_sponsor_logo_placement_url(sponsor, logo_placement)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_admin_panel_sponsor_logo_placement_url(sponsor)
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'renders a successful response' do
      logo_placement = sponsor.logo_placements.create! valid_attributes
      get edit_admin_panel_sponsor_logo_placement_url(sponsor, logo_placement)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new AdminPanel::LogoPlacement' do
        expect do
          post admin_panel_sponsor_logo_placements_url(sponsor),
               params: { logo_placement: valid_attributes }
        end.to change(AdminPanel::LogoPlacement, :count).by(1)
      end

      it 'redirects to the sponsor' do
        post admin_panel_sponsor_logo_placements_url(sponsor),
             params: { logo_placement: valid_attributes }
        expect(response).to redirect_to(admin_panel_sponsor_url(sponsor))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new AdminPanel::LogoPlacement' do
        expect do
          post admin_panel_sponsor_logo_placements_url(sponsor),
               params: { logo_placement: invalid_attributes }
        end.to change(AdminPanel::LogoPlacement, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post admin_panel_sponsor_logo_placements_url(sponsor),
             params: { logo_placement: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) do
        {
          page_name: 'about',
          section: 'footer',
          displayed: false
        }
      end

      it 'updates the requested admin_panel_logo_placement' do
        logo_placement = sponsor.logo_placements.create! valid_attributes
        patch admin_panel_sponsor_logo_placement_url(sponsor, logo_placement),
              params: { logo_placement: new_attributes }
        logo_placement.reload
        expect(logo_placement.page_name).to eq('about')
        expect(logo_placement.section).to eq('footer')
        expect(logo_placement.displayed).to eq(false)
      end

      it 'redirects to the sponsor' do
        logo_placement = sponsor.logo_placements.create! valid_attributes
        patch admin_panel_sponsor_logo_placement_url(sponsor, logo_placement),
              params: { logo_placement: new_attributes }
        logo_placement.reload
        expect(response).to redirect_to(admin_panel_sponsor_url(sponsor))
      end
    end

    context 'with invalid parameters' do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        logo_placement = sponsor.logo_placements.create! valid_attributes
        patch admin_panel_sponsor_logo_placement_url(sponsor, logo_placement),
              params: { logo_placement: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested admin_panel_logo_placement' do
      logo_placement = sponsor.logo_placements.create! valid_attributes
      expect do
        delete admin_panel_sponsor_logo_placement_url(sponsor, logo_placement)
      end.to change(AdminPanel::LogoPlacement, :count).by(-1)
    end

    it 'redirects to the sponsor' do
      logo_placement = sponsor.logo_placements.create! valid_attributes
      delete admin_panel_sponsor_logo_placement_url(sponsor, logo_placement)
      expect(response).to redirect_to(admin_panel_sponsor_url(sponsor))
    end
  end
end
