Rails.application.routes.draw do
  root 'home#index'
  get 'homepage', to: 'home#homepage', as: :homepage

  # Allow viewing all resumes
  resources :resumes, only: [:index, :show, :edit, :update, :destroy]

  # Nested resume routes for user-specific actions
  resources :users do
    resource :resume, only: [:new, :create, :show, :edit, :update, :destroy]
  end

  devise_for :admins, controllers: { omniauth_callbacks: 'admins/omniauth_callbacks' }
  devise_scope :admin do
    # Render sign-in page which posts to Google OAuth (OmniAuth 2.x requires POST)
    get 'admins/sign_in', to: 'admins/sessions#new', as: :new_admin_session
    get 'admins/sign_out', to: 'admins/sessions#destroy', as: :destroy_admin_session
  end

  namespace :admin_panel do
    # get "events/index"
    # get "events/show"
    # get "events/new"
    # get "events/create"
    # get "events/edit"
    # get "events/update"
    # get "events/destroy"
    # get "dashboard/index"
    get 'dashboard', to: 'dashboard#index'
    resources :events
    # resources :sponsors
    # resources :resumes, only: [:index]
    # resources :applications, only: [:index]
  end
end
