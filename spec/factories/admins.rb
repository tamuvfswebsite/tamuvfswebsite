FactoryBot.define do
  factory :admin do
    email { "admin#{rand(1000)}@example.com" }
    full_name { 'Test Admin' }
    uid { SecureRandom.uuid }
    avatar_url { 'https://example.com/avatar.png' }
  end
end
