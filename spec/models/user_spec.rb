require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it 'belongs to organizational_role optionally' do
      user = create_user
      expect(user.organizational_role).to be_nil
      expect(user).to be_valid
    end

    it 'can have an organizational_role' do
      role = OrganizationalRole.create!(name: 'AI Team')
      user = create_user(organizational_role: role)

      expect(user.organizational_role).to eq(role)
      expect(user.organizational_role.name).to eq('AI Team')
    end
  end

  describe 'role attribute' do
    it 'can be set to user' do
      user = create_user(role: 'user')
      expect(user.role).to eq('user')
    end

    it 'can be set to admin' do
      user = create_user(role: 'admin')
      expect(user.role).to eq('admin')
    end

    it 'can be set to sponsor' do
      user = create_user(role: 'sponsor')
      expect(user.role).to eq('sponsor')
    end
  end

  describe 'validations' do
    it 'requires google_uid' do
      user = User.new(
        email: 'test@example.com',
        first_name: 'Test',
        last_name: 'User'
      )
      expect(user).not_to be_valid
      expect(user.errors[:google_uid]).to include("can't be blank")
    end

    it 'requires unique google_uid' do
      create_user(uid: 'unique123')
      duplicate = User.new(
        google_uid: 'unique123',
        email: 'another@example.com',
        first_name: 'Another',
        last_name: 'User'
      )
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:google_uid]).to include('has already been taken')
    end

    it 'requires email' do
      user = User.new(
        google_uid: 'test123',
        first_name: 'Test',
        last_name: 'User'
      )
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'requires unique email' do
      create_user(email: 'unique@example.com')
      duplicate = User.new(
        google_uid: 'different123',
        email: 'unique@example.com',
        first_name: 'Another',
        last_name: 'User'
      )
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include('has already been taken')
    end
  end
end
