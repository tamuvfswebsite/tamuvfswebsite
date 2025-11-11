# frozen_string_literal: true

module RoleApplicationAuthorization
  extend ActiveSupport::Concern

  private

  # Authenticate user via current_user helper (assumes OAuth flow sets this)
  def authenticate_user_for_application
    return if current_user

    # Store the location they're trying to access
    session[:applying_for_role] = true
    # Redirect to OAuth for authentication
    redirect_to admin_google_oauth2_omniauth_authorize_path, alert: 'Please sign in to apply.'
  end

  # Prevent sponsors from accessing role application forms
  def prevent_sponsor_access
    return unless current_user&.sponsor?

    redirect_to root_path, alert: 'Sponsors cannot apply for organizational roles.'
  end

  # Check if user has reached the application limit
  def check_application_limit
    return unless current_user.role_applications.count >= 10

    redirect_to root_path, alert: 'You have reached the maximum limit of 10 applications.'
  end

  # Check if user has a resume (used in new/create)
  def check_resume_present
    return if current_user.resume&.file&.attached?

    redirect_to new_user_resume_path(current_user, return_to: 'application'),
                alert: 'Please upload your resume before applying.'
  end

  def authorize_role_application_access
    unless current_user
      session[:applying_for_role] = true
      redirect_to admin_google_oauth2_omniauth_authorize_path, alert: 'Please sign in to view this application.'
      return
    end

    # Allow admins to view any application
    return if admin_signed_in? && current_user.role == 'admin'

    # Allow users to view only their own application
    return if @role_application&.user_id == current_user.id

    redirect_to root_path, alert: 'You can only view your own application.'
  end
end
