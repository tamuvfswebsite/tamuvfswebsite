class Admins::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    admin = Admin.from_google(**from_google_params)

    # Create or update user record
    user = create_or_update_user

    # Store user session for application flow (for non-admin users)
    session[:user_id] = user.id if user.present?

    # Check if they're trying to apply for a role (only if flag is set)
    if session[:applying_for_role]
      session.delete(:applying_for_role)

      # Sign in the admin if they are one (maintains admin session)
      if admin.present?
        sign_out_all_scopes
        sign_in(:admin, admin)
      end

      # Check if user has reached application limit (now supports multiple applications)
      if user.role_applications.count >= 10
        flash[:alert] = 'You have reached the maximum limit of 10 applications.'
        redirect_to role_applications_path
      else
        # Redirect to application page
        # Session is now properly established for both admins and users
        redirect_to new_role_application_path
      end
    elsif admin.present?
      # Normal sign-in - clear any stale apply flag
      session.delete(:applying_for_role)
      # Normal admin sign-in flow
      sign_out_all_scopes
      flash[:success] = t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in(:admin, admin)
      redirect_to root_path
    else
      # Not an admin and not applying - deny access
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
    stored_location_for(resource_or_scope) || root_path
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

    user
  end
end
