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

  describe 'application questions' do
    it 'allows optional question_1' do
      role = OrganizationalRole.new(name: 'AI Team')
      expect(role).to be_valid
      expect(role.question_1).to be_nil
    end

    it 'allows optional question_2' do
      role = OrganizationalRole.new(name: 'AI Team')
      expect(role).to be_valid
      expect(role.question_2).to be_nil
    end

    it 'allows optional question_3' do
      role = OrganizationalRole.new(name: 'AI Team')
      expect(role).to be_valid
      expect(role.question_3).to be_nil
    end

    it 'allows setting custom questions' do
      role = OrganizationalRole.create!(
        name: 'Engineering Team',
        question_1: 'What programming languages are you proficient in?',
        question_2: 'Describe a challenging technical problem you solved.',
        question_3: 'Why do you want to join our engineering team?'
      )
      expect(role.question_1).to eq('What programming languages are you proficient in?')
      expect(role.question_2).to eq('Describe a challenging technical problem you solved.')
      expect(role.question_3).to eq('Why do you want to join our engineering team?')
    end

    it 'allows partial question sets' do
      role = OrganizationalRole.create!(
        name: 'Marketing Team',
        question_1: 'What marketing experience do you have?',
        question_2: 'Describe a successful campaign you worked on.'
      )
      expect(role.question_1).to be_present
      expect(role.question_2).to be_present
      expect(role.question_3).to be_nil
    end
  end

  describe 'associations' do
    it 'has many users' do
      role = OrganizationalRole.create!(name: 'AI Team')
      user1 = create_user
      user2 = create_user
      user1.organizational_roles << role
      user2.organizational_roles << role

      expect(role.users).to include(user1, user2)
      expect(role.users.count).to eq(2)
    end

    it 'destroys organizational_role_users join records when deleted' do
      role = OrganizationalRole.create!(name: 'Design Team')
      user = create_user
      user.organizational_roles << role

      expect(user.organizational_roles).to include(role)

      role.destroy!
      user.reload

      expect(user.organizational_roles).to be_empty
    end
  end
end
