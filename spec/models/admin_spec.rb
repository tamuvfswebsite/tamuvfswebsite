require 'rails_helper'

RSpec.describe Admin, type: :model do
  describe '.from_google' do
    it 'creates a new admin from Google OAuth data' do
      expect do
        Admin.from_google(
          email: 'test@example.com',
          full_name: 'Test User',
          uid: '12345',
          avatar_url: 'https://example.com/avatar.jpg'
        )
      end.to change(Admin, :count).by(1)

      admin = Admin.last
      expect(admin.email).to eq('test@example.com')
      expect(admin.full_name).to eq('Test User')
      expect(admin.uid).to eq('12345')
      expect(admin.avatar_url).to eq('https://example.com/avatar.jpg')
    end

    it 'finds existing admin instead of creating duplicate' do
      Admin.create!(
        email: 'existing@example.com',
        full_name: 'Existing User',
        uid: '99999',
        avatar_url: 'https://example.com/old.jpg'
      )

      expect do
        Admin.from_google(
          email: 'existing@example.com',
          full_name: 'Updated Name',
          uid: '99999',
          avatar_url: 'https://example.com/new.jpg'
        )
      end.not_to change(Admin, :count)
    end
  end
end
