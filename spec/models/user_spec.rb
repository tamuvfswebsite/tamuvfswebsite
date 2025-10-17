require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it 'has no organizational_roles by default' do
      user = create_user
      expect(user.organizational_roles).to be_empty
      expect(user).to be_valid
    end

    it 'can have multiple organizational_roles' do
      role1 = OrganizationalRole.create!(name: 'AI Team')
      role2 = OrganizationalRole.create!(name: 'Design Team')
      user = create_user
      user.organizational_roles << [role1, role2]

      expect(user.organizational_roles).to include(role1, role2)
      expect(user.organizational_roles.count).to eq(2)
      expect(user.organizational_roles.pluck(:name)).to match_array(['AI Team', 'Design Team'])
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
