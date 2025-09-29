class ApplicationController < ActionController::Base
  # Base controller for all controllers
  helper_method :admin_user?

  private

  def ensure_admin_user
    unless admin_signed_in?
      flash[:alert] = 'Access denied. Admin privileges required.'
      redirect_to root_path
      return
    end

    current_user = User.find_by(google_uid: current_admin.uid)

    return if current_user&.role == 'admin'

    flash[:alert] = 'Access denied. Admin privileges required.'
    redirect_to root_path
  end

  def admin_user?
    return false unless admin_signed_in?

    user = User.find_by(google_uid: current_admin.uid)
    user&.role == 'admin'
  end
end
