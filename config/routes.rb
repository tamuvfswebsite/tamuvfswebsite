Rails.application.routes.draw do
  root 'home#index'
  get 'homepage', to: 'home#homepage', as: :homepage

  # Public check-in endpoint (token-based)
  get  'checkin', to: 'checkins#new',    as: :checkin
  post 'checkin', to: 'checkins#create', as: :perform_checkin

  # Allow viewing all resumes
  resources :resumes, only: %i[index show edit update destroy]

  # Nested resume routes for user-specific actions
  resources :users do
    resource :resume, only: %i[new create show edit update destroy]
  end

  devise_for :admins, controllers: { omniauth_callbacks: 'admins/omniauth_callbacks' }
  devise_scope :admin do
    # Render sign-in page which posts to Google OAuth (OmniAuth 2.x requires POST)
    get 'admins/sign_in', to: 'admins/sessions#new', as: :new_admin_session
    get 'admins/sign_out', to: 'admins/sessions#destroy', as: :destroy_admin_session
  end

  namespace :admin_panel do
    root to: 'dashboard#index'
    # get "events/index"
    # get "events/show"
    # get "events/new"
    # get "events/create"
    # get "events/edit"
    # get "events/update"
    # get "events/destroy"
    # get "dashboard/index"
    get 'dashboard', to: 'dashboard#index'
    get 'leaderboard', to: 'dashboard#leaderboard'
    resources :events
    resources :attendance_links, only: %i[new create]
    resources :organizational_roles
    # resources :sponsors
    # resources :resumes, only: [:index]
    # resources :applications, only: [:index]
  end
end
