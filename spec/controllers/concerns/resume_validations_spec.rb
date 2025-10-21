require 'rails_helper'

RSpec.describe ResumeValidations, type: :controller do
  controller(ApplicationController) do
    include ResumeValidations

    def test_validate_user_for_create
      @user = User.find_by(id: params[:user_id])
      validate_user_for_create
      return if performed?

      render json: { valid: true }
    end

    def test_validate_user_and_resume_for_update
      @user = User.find_by(id: params[:user_id])
      @resume = Resume.find_by(id: params[:id])
      validate_user_and_resume_for_update
      return if performed?

      render json: { valid: true }
    end
  end

  before do
    routes.draw do
      get 'test_validate_user_for_create' => 'anonymous#test_validate_user_for_create'
      get 'test_validate_user_and_resume_for_update' => 'anonymous#test_validate_user_and_resume_for_update'
    end
  end

  describe '#validate_user_for_create' do
    it 'succeeds when user exists and has no resume' do
      user = create_user

      get :test_validate_user_for_create, params: { user_id: user.id }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['valid']).to eq(true)
    end

    it 'redirects when user does not exist' do
      get :test_validate_user_for_create, params: { user_id: 99_999 }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('User not found')
    end

    it 'redirects when user already has a resume' do
      user = create_user
      Resume.create!(user: user, file: fixture_file_upload('spec/fixtures/test.pdf', 'application/pdf'))

      get :test_validate_user_for_create, params: { user_id: user.id }
      expect(response).to redirect_to(user)
      expect(flash[:alert]).to eq('You already have a resume.')
    end
  end

  describe '#validate_user_and_resume_for_update' do
    let(:user) { create_user }
    let(:resume) { Resume.create!(user: user, file: fixture_file_upload('spec/fixtures/test.pdf', 'application/pdf')) }

    it 'succeeds when user and resume exist and match' do
      get :test_validate_user_and_resume_for_update, params: { user_id: user.id, id: resume.id }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['valid']).to eq(true)
    end

    it 'redirects when user does not exist' do
      get :test_validate_user_and_resume_for_update, params: { user_id: 99_999, id: resume.id }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('Resume not found')
    end

    it 'redirects when resume does not exist' do
      get :test_validate_user_and_resume_for_update, params: { user_id: user.id, id: 99_999 }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('Resume not found')
    end

    it 'redirects when resume does not belong to the user' do
      other_user = create_user(uid: 'other123')

      get :test_validate_user_and_resume_for_update, params: { user_id: other_user.id, id: resume.id }
      expect(response).to redirect_to(user_path(other_user))
      expect(flash[:alert]).to eq('You can only update your own resume.')
    end
  end
end
