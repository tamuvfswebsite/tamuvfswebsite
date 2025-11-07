Rails.application.routes.draw do
  # Root and basic pages
  root 'home#index'
  get 'apply', to: 'home#apply', as: :apply

  # Sponsor dashboard
  get 'sponsor_dashboard/index'
  resource :sponsor, only: %i[show edit update]

  # Public check-in (token-based)
  get  'checkin', to: 'checkins#new',    as: :checkin
  post 'checkin', to: 'checkins#create', as: :perform_checkin

  # Resumes
  resources :resumes, only: %i[index show edit update destroy] do
    member { get :download }
  end

  # Events & RSVPs
  resources :events, only: %i[index show] do
    resource :rsvp, only: %i[create update], controller: 'event_rsvps'
  end

  # Users & their resumes
  resources :users do
    resource :resume, only: %i[new create show edit update destroy]
  end

  # Role applications
  resources :role_applications, only: %i[new create show edit update]

  # Admin authentication (Devise + OmniAuth)
  devise_for :admins, controllers: { omniauth_callbacks: 'admins/omniauth_callbacks' }

  devise_scope :admin do
    get 'admins/sign_in',  to: 'admins/sessions#new',     as: :new_admin_session
    get 'admins/sign_out', to: 'admins/sessions#destroy', as: :destroy_admin_session
  end

  # Admin Panel
  namespace :admin_panel do
    root to: 'dashboard#index'

    get 'dashboard',   to: 'dashboard#index'
    get 'leaderboard', to: 'dashboard#leaderboard'

    resources :events
    resources :attendance_links, only: %i[new create]
    resources :organizational_roles

    resources :role_applications, only: %i[index show destroy] do
      patch :update_status, on: :member
    end

    resources :sponsors do
      resources :logo_placements, except: %i[index]
      member do
        get   :assign_users
        patch :update_users
      end
      # Future sponsor routes (e.g., resumes, applications)
      # resources :resumes, only: [:index]
      # resources :applications, only: [:index]
    end
  end
end
