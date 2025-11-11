module AuthHelpers
  # rubocop:disable Metrics/ParameterLists
  def create_user(role: 'user', organizational_roles: [], uid: nil, email: nil, first_name: 'Test', last_name: 'User')
    # rubocop:enable Metrics/ParameterLists
    uid ||= SecureRandom.hex(10)
    email ||= "user_#{uid}@test.com"

    user = User.create!(
      google_uid: uid,
      email: email,
      first_name: first_name,
      last_name: last_name,
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
    # Use Devise's sign_in helper with explicit scope for request specs
    sign_in(admin, scope: :admin)
  end

  # Helper to sign in a user as admin in view/controller specs
  def sign_in_user(user)
    admin = create_admin_from_user(user)
    setup_view_stubs(admin)
    admin
  end

  private

  def create_admin_from_user(user)
    Admin.find_or_create_by!(
      email: user.email,
      uid: user.google_uid,
      full_name: "#{user.first_name} #{user.last_name}"
    )
  end

  def setup_view_stubs(admin)
    return unless respond_to?(:view)

    allow(view).to receive(:admin_signed_in?).and_return(true)
    allow(view).to receive(:current_admin).and_return(admin)
  end
end
