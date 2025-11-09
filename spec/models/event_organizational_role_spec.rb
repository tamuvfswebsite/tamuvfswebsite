require 'rails_helper'

RSpec.describe EventOrganizationalRole, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:event) }
    it { is_expected.to belong_to(:organizational_role) }
  end

  describe 'validations' do
    let(:event) { Event.create!(title: 'Test Event', event_date: 1.day.from_now, location: 'Test', capacity: 50) }
    let(:role) { OrganizationalRole.create!(name: 'Test Role', description: 'Test') }

    it 'is valid with valid attributes' do
      event_role = EventOrganizationalRole.new(event: event, organizational_role: role)
      expect(event_role).to be_valid
    end

    it 'is invalid without an event' do
      event_role = EventOrganizationalRole.new(organizational_role: role)
      expect(event_role).not_to be_valid
    end

    it 'is invalid without an organizational_role' do
      event_role = EventOrganizationalRole.new(event: event)
      expect(event_role).not_to be_valid
    end

    it 'prevents duplicate event-role combinations' do
      EventOrganizationalRole.create!(event: event, organizational_role: role)
      duplicate = EventOrganizationalRole.new(event: event, organizational_role: role)
      expect(duplicate).not_to be_valid
    end
  end
end

