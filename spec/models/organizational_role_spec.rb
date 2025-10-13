require 'rails_helper'

RSpec.describe OrganizationalRole, type: :model do
  describe 'validations' do
    it 'requires a name' do
      role = OrganizationalRole.new(name: nil)
      expect(role).not_to be_valid
      expect(role.errors[:name]).to include("can't be blank")
    end

    it 'requires a unique name' do
      OrganizationalRole.create!(name: 'Engineering Team')
      duplicate_role = OrganizationalRole.new(name: 'Engineering Team')
      expect(duplicate_role).not_to be_valid
      expect(duplicate_role.errors[:name]).to include('has already been taken')
    end

    it 'allows a valid organizational role' do
      role = OrganizationalRole.new(name: 'Marketing Team', description: 'Marketing department')
      expect(role).to be_valid
    end

    it 'allows optional description' do
      role = OrganizationalRole.new(name: 'Sales Team')
      expect(role).to be_valid
    end
  end

  describe 'associations' do
    it 'has many users' do
      role = OrganizationalRole.create!(name: 'AI Team')
      user1 = create_user(organizational_role: role)
      user2 = create_user(organizational_role: role)

      expect(role.users).to include(user1, user2)
      expect(role.users.count).to eq(2)
    end

    it 'nullifies user organizational_role_id when deleted' do
      role = OrganizationalRole.create!(name: 'Design Team')
      user = create_user(organizational_role: role)

      expect(user.organizational_role_id).to eq(role.id)

      role.destroy!
      user.reload

      expect(user.organizational_role_id).to be_nil
    end
  end
end
