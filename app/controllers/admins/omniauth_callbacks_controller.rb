class Admins::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    admin = Admin.from_google(**from_google_params)

    # Create or update user record
    create_or_update_user

    if admin.present?
      sign_out_all_scopes
      flash[:success] = t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in_and_redirect admin, event: :authentication
    else
      flash[:alert] =
        t 'devise.omniauth_callbacks.failure', kind: 'Google', reason: "#{auth.info.email} is not authorized."
      redirect_to new_admin_session_path
    end
  end

  protected

  def after_omniauth_failure_path_for(_scope)
    new_admin_session_path
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || homepage_path
  end

  private

  def from_google_params
    @from_google_params ||= {
      uid: auth.uid,
      email: auth.info.email,
      full_name: auth.info.name,
      avatar_url: auth.info.image
    }
  end

  def auth
    @auth ||= request.env['omniauth.auth']
  end

  def create_or_update_user
    # Split full_name into first_name and last_name
    name_parts = auth.info.name.split(' ', 2)
    first_name = name_parts[0]
    last_name = name_parts[1] || ''

    user = User.find_or_create_by(google_uid: auth.uid) do |user|
      user.email = auth.info.email
      user.first_name = first_name
      user.last_name = last_name
      user.role = Rails.env.development? ? 'admin' : 'user'
      user.google_avatar_url = auth.info.image
    end

    # Update avatar URL on each login to keep it fresh
    user.update(google_avatar_url: auth.info.image) if user.persisted?
  end
end
