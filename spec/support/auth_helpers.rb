module AuthHelpers
  def create_user(role: 'user', organizational_roles: [], uid: nil, email: nil)
    uid ||= SecureRandom.hex(10)
    email ||= "user_#{uid}@test.com"

    user = User.create!(
      google_uid: uid,
      email: email,
      first_name: 'Test',
      last_name: 'User',
      role: role,
      google_avatar_url: 'https://example.com/avatar.jpg'
    )

    # Add organizational roles if provided
    Array(organizational_roles).each do |org_role|
      user.organizational_roles << org_role
    end

    user
  end

  # Sign in as an admin for request specs
  def sign_in_as_admin(user)
    admin = Admin.find_or_create_by!(
      email: user.email,
      uid: user.google_uid,
      full_name: "#{user.first_name} #{user.last_name}"
    )
    sign_in admin
  end

  # Helper to sign in a user as admin in view/controller specs
  def sign_in_user(user)
    admin = Admin.find_or_create_by!(
      email: user.email,
      uid: user.google_uid,
      full_name: "#{user.first_name} #{user.last_name}"
    )
    allow(view).to receive(:admin_signed_in?).and_return(true) if respond_to?(:view)
    allow(view).to receive(:current_admin).and_return(admin) if respond_to?(:view)
    admin
  end
end
