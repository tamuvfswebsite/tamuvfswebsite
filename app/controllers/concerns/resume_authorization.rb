# frozen_string_literal: true

module ResumeAuthorization
  extend ActiveSupport::Concern

  private

  # Only admins and sponsors can view all resumes
  def authorize_admin_or_sponsor
    unless admin_signed_in?
      redirect_to root_path, alert: 'Access denied. Please sign in.'
      return
    end

    current_user = User.find_by(google_uid: current_admin.uid)
    return if current_user&.role&.in?(%w[admin sponsor])

    redirect_to root_path, alert: 'Access denied. Admins and sponsors only.'
  end

  # Users can view their own resume, admins can view any resume
  def authorize_own_resume
    unless admin_signed_in?
      redirect_to root_path, alert: 'Access denied. Please sign in.'
      return
    end

    current_user = User.find_by(google_uid: current_admin.uid)

    unless current_user
      redirect_to root_path, alert: 'User account not found. Please contact support.'
      return
    end

    # Allow if user is an admin
    return if current_user.role == 'admin'

    # Otherwise, only allow viewing own resume (compare by ID for reliable comparison)
    return if @resume&.user_id == current_user.id

    redirect_to root_path, alert: 'You can only view your own resume.'
  end
end
