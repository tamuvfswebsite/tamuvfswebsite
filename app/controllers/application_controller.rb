class ApplicationController < ActionController::Base
  helper_method :admin_user?, :sponsor_user?, :current_user

  def current_user
    @current_user ||= User.find_by(google_uid: current_admin&.uid)
  end

  private

  # --- Access Control Helpers ---

  def ensure_admin_user
    return if admin_user?

    flash[:alert] = 'Access denied. Admin privileges required.'
    redirect_to root_path
  end

  def ensure_sponsor_user
    return if sponsor_user?

    flash[:alert] =
      current_user.present? ? 'Access denied. Sponsor privileges required.' : 'You need to sign in first.'
    redirect_to root_path
  end

  # --- Role Check Helpers ---

  def admin_user?
    current_user&.role == 'admin' && admin_signed_in?
  end

  def sponsor_user?
    current_user&.role == 'sponsor'
  end
end
