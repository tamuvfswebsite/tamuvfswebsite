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
end
