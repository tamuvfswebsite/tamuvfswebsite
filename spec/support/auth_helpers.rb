module AuthHelpers
  def create_user(role: 'user', organizational_role: nil, uid: nil, email: nil)
    uid ||= SecureRandom.hex(10)
    email ||= "user_#{uid}@test.com"

    User.create!(
      google_uid: uid,
      email: email,
      first_name: 'Test',
      last_name: 'User',
      role: role,
      organizational_role: organizational_role,
      google_avatar_url: 'https://example.com/avatar.jpg'
    )
  end
end
