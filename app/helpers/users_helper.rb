module UsersHelper
  # Check if the current admin user is viewing/editing their own account
  def is_own_account(user)
    admin_signed_in? && user.google_uid == current_admin.uid
  end
  alias_method :editing_own_profile?, :is_own_account
end
