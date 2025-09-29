Rails.application.routes.draw do
  root 'home#index'

  # Allow viewing all resumes
  resources :resumes, only: [:index, :show, :edit, :update, :destroy]

  # Nested resume routes for user-specific actions
  resources :users do
    resource :resume, only: [:new, :create, :show, :edit, :update, :destroy]
  end

  devise_for :admins, controllers: { omniauth_callbacks: 'admins/omniauth_callbacks' }
  devise_scope :admin do
    get 'admins/sign_in', to: 'admins/sessions#new', as: :new_admin_session
    get 'admins/sign_out', to: 'admins/sessions#destroy', as: :destroy_admin_session
  end
end
