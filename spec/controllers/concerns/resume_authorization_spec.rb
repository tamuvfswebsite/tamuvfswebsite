require 'rails_helper'

RSpec.describe ResumeAuthorization, type: :controller do
  controller(ApplicationController) do
    include ResumeAuthorization

    def test_current_authenticated_user
      render json: { user_id: current_authenticated_user&.id }
    end

    def test_authorize_admin_or_sponsor
      authorize_admin_or_sponsor
      return if performed?

      render json: { authorized: true }
    end

    def test_authorize_own_resume
      authorize_own_resume
      return if performed?

      render json: { authorized: true }
    end
  end

  before do
    routes.draw do
      get 'test_current_authenticated_user' => 'anonymous#test_current_authenticated_user'
      get 'test_authorize_admin_or_sponsor' => 'anonymous#test_authorize_admin_or_sponsor'
      get 'test_authorize_own_resume' => 'anonymous#test_authorize_own_resume'
    end
  end

  describe '#current_authenticated_user' do
    it 'returns the user when admin is signed in and user exists' do
      user = create_user(uid: 'user123')
      admin = double('Admin', uid: 'user123')

      allow(controller).to receive(:admin_signed_in?).and_return(true)
      allow(controller).to receive(:current_admin).and_return(admin)

      get :test_current_authenticated_user
      expect(JSON.parse(response.body)['user_id']).to eq(user.id)
    end

    it 'returns nil when admin is not signed in' do
      allow(controller).to receive(:admin_signed_in?).and_return(false)
      allow(controller).to receive(:current_admin).and_return(nil)

      get :test_current_authenticated_user
      expect(JSON.parse(response.body)['user_id']).to be_nil
    end

    it 'returns nil when admin is signed in but user does not exist' do
      admin = double('Admin', uid: 'nonexistent')
      allow(controller).to receive(:admin_signed_in?).and_return(true)
      allow(controller).to receive(:current_admin).and_return(admin)

      get :test_current_authenticated_user
      expect(JSON.parse(response.body)['user_id']).to be_nil
    end
  end

  describe '#authorize_admin_or_sponsor' do
    it 'allows admin users to proceed' do
      create_user(role: 'admin', uid: 'admin123')
      admin = double('Admin', uid: 'admin123')

      allow(controller).to receive(:admin_signed_in?).and_return(true)
      allow(controller).to receive(:current_admin).and_return(admin)

      get :test_authorize_admin_or_sponsor
      expect(response).to have_http_status(:success)
    end

    it 'allows sponsor users to proceed' do
      create_user(role: 'sponsor', uid: 'sponsor123')
      admin = double('Admin', uid: 'sponsor123')

      allow(controller).to receive(:admin_signed_in?).and_return(true)
      allow(controller).to receive(:current_admin).and_return(admin)

      get :test_authorize_admin_or_sponsor
      expect(response).to have_http_status(:success)
    end

    it 'redirects regular users with alert message' do
      create_user(role: 'user', uid: 'user123')
      admin = double('Admin', uid: 'user123')

      allow(controller).to receive(:admin_signed_in?).and_return(true)
      allow(controller).to receive(:current_admin).and_return(admin)

      get :test_authorize_admin_or_sponsor
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('Access denied. Admins and sponsors only.')
    end

    it 'redirects when not signed in' do
      allow(controller).to receive(:admin_signed_in?).and_return(false)
      allow(controller).to receive(:current_admin).and_return(nil)

      get :test_authorize_admin_or_sponsor
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('Access denied. Please sign in.')
    end
  end

  describe '#authorize_own_resume' do
    let(:user) { create_user(uid: 'user123') }
    let(:resume) { Resume.create!(user: user, file: fixture_file_upload('spec/fixtures/test.pdf', 'application/pdf')) }

    it 'allows user to access their own resume' do
      admin = double('Admin', uid: 'user123')
      allow(controller).to receive(:admin_signed_in?).and_return(true)
      allow(controller).to receive(:current_admin).and_return(admin)
      controller.instance_variable_set(:@resume, resume)

      get :test_authorize_own_resume
      expect(response).to have_http_status(:success)
    end

    it 'redirects when user tries to access another user\'s resume' do
      create_user(uid: 'other123')
      admin = double('Admin', uid: 'other123')

      allow(controller).to receive(:admin_signed_in?).and_return(true)
      allow(controller).to receive(:current_admin).and_return(admin)
      controller.instance_variable_set(:@resume, resume)

      get :test_authorize_own_resume
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('You can only view your own resume.')
    end

    it 'redirects when not signed in' do
      allow(controller).to receive(:admin_signed_in?).and_return(false)
      allow(controller).to receive(:current_admin).and_return(nil)
      controller.instance_variable_set(:@resume, resume)

      get :test_authorize_own_resume
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('Access denied. Please sign in.')
    end
  end
end
