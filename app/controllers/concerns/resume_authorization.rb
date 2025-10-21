# frozen_string_literal: true

module ResumeAuthorization
  extend ActiveSupport::Concern

  private

  def current_authenticated_user
    return unless admin_signed_in?

    @current_authenticated_user ||= User.find_by(google_uid: current_admin.uid)
  end

  # Only admins and sponsors can view all resumes
  def authorize_admin_or_sponsor
    unless admin_signed_in?
      redirect_to root_path, alert: 'Access denied. Please sign in.'
      return
    end

    return if current_authenticated_user&.role&.in?(%w[admin sponsor])

    redirect_to root_path, alert: 'Access denied. Admins and sponsors only.'
  end

  # Users can view their own resume, admins and sponsors can view any resume
  def authorize_own_resume
    unless admin_signed_in?
      redirect_to root_path, alert: 'Access denied. Please sign in.'
      return
    end

    unless current_authenticated_user
      redirect_to root_path, alert: 'User account not found. Please contact support.'
      return
    end

    # Allow if user is an admin or sponsor
    return if current_authenticated_user.role&.in?(%w[admin sponsor])

    # Otherwise, only allow viewing own resume
    return if @resume&.user_id == current_authenticated_user.id

    redirect_to root_path, alert: 'You can only view your own resume.'
  end
end
