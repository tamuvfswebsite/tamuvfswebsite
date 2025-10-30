module UsersHelper
  # Check if the current admin user is viewing/editing their own account
  def own_account?(user)
    admin_signed_in? && user.google_uid == current_admin.uid
  end
  alias editing_own_profile? own_account?
end
