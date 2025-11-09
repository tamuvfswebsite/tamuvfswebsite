require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      event = Event.new(
        title: 'Test Event',
        event_date: 1.day.from_now,
        description: 'Test description',
        location: 'Test location',
        capacity: 50
      )
      expect(event).to be_valid
    end

    it 'is invalid without a title' do
      event = Event.new(title: nil, event_date: 1.day.from_now, location: 'Test', capacity: 50)
      expect(event).not_to be_valid
      expect(event.errors[:title]).to be_present
    end

    it 'is invalid with a title shorter than 3 characters' do
      event = Event.new(title: 'AB', event_date: 1.day.from_now, location: 'Test', capacity: 50)
      expect(event).not_to be_valid
      expect(event.errors[:title]).to be_present
    end

    it 'is invalid without an event_date' do
      event = Event.new(title: 'Test Event', event_date: nil, location: 'Test', capacity: 50)
      expect(event).not_to be_valid
      expect(event.errors[:event_date]).to be_present
    end

    it 'is invalid with a past event_date' do
      event = Event.new(
        title: 'Test Event',
        event_date: 1.day.ago,
        description: 'Test',
        location: 'Test',
        capacity: 50
      )
      expect(event).not_to be_valid
      expect(event.errors[:event_date]).to include("can't be in the past")
    end

    it 'is invalid without a location' do
      event = Event.new(title: 'Test Event', event_date: 1.day.from_now, location: nil, capacity: 50)
      expect(event).not_to be_valid
      expect(event.errors[:location]).to be_present
    end

    it 'is invalid without capacity' do
      event = Event.new(title: 'Test Event', event_date: 1.day.from_now, location: 'Test', capacity: nil)
      expect(event).not_to be_valid
      expect(event.errors[:capacity]).to be_present
    end

    it 'is invalid with capacity less than or equal to 0' do
      event = Event.new(title: 'Test Event', event_date: 1.day.from_now, location: 'Test', capacity: 0)
      expect(event).not_to be_valid
      expect(event.errors[:capacity]).to be_present
    end
  end

  describe 'associations' do
    it 'has many event_organizational_roles' do
      event = Event.create!(
        title: 'Test Event',
        event_date: 1.day.from_now,
        location: 'Test',
        capacity: 50
      )
      role = OrganizationalRole.create!(name: 'AI', description: 'AI Role')
      event.organizational_roles << role

      expect(event.event_organizational_roles.count).to eq(1)
      expect(event.organizational_roles).to include(role)
    end

    it 'destroys event_organizational_roles when event is deleted' do
      event = Event.create!(
        title: 'Test Event',
        event_date: 1.day.from_now,
        location: 'Test',
        capacity: 50
      )
      role = OrganizationalRole.create!(name: 'AI', description: 'AI Role')
      event.organizational_roles << role

      event.destroy!
      expect(EventOrganizationalRole.where(event_id: event.id)).to be_empty
    end
  end

  describe 'scopes' do
    let!(:future_event) do
      Event.create!(title: 'Future Event', event_date: 1.day.from_now, location: 'Test', capacity: 50)
    end
    let!(:past_event) do
      # Create with future date, then update to past to bypass validation
      event = Event.create!(title: 'Past Event', event_date: 1.day.from_now, location: 'Test', capacity: 50)
      event.update_column(:event_date, 1.day.ago)
      event
    end

    it 'returns future events' do
      expect(Event.future_events).to include(future_event)
      expect(Event.future_events).not_to include(past_event)
    end

    it 'returns past events' do
      expect(Event.past_events).to include(past_event)
      expect(Event.past_events).not_to include(future_event)
    end

    it 'returns published events' do
      published_event = Event.create!(
        title: 'Published Event',
        event_date: 1.day.from_now,
        location: 'Test',
        capacity: 50,
        is_published: true
      )
      unpublished_event = Event.create!(
        title: 'Unpublished Event',
        event_date: 1.day.from_now,
        location: 'Test',
        capacity: 50,
        is_published: false
      )

      expect(Event.published).to include(published_event)
      expect(Event.published).not_to include(unpublished_event)
    end

    describe 'public_events scope' do
      let!(:public_event) do
        Event.create!(
          title: 'Public Event',
          event_date: 1.day.from_now,
          location: 'Test',
          capacity: 50,
          is_public: true
        )
      end
      let!(:private_event) do
        Event.create!(
          title: 'Private Event',
          event_date: 1.day.from_now,
          location: 'Test',
          capacity: 50,
          is_public: false
        )
      end

      it 'returns only public events' do
        expect(Event.public_events).to include(public_event)
        expect(Event.public_events).not_to include(private_event)
      end
    end

    describe 'for_organizational_role scope' do
      let(:ai_role) { OrganizationalRole.create!(name: 'AI', description: 'AI Role') }
      let(:design_role) { OrganizationalRole.create!(name: 'Design', description: 'Design Role') }
      let!(:ai_event) do
        event = Event.create!(
          title: 'AI Event',
          event_date: 1.day.from_now,
          location: 'Test',
          capacity: 50
        )
        event.organizational_roles << ai_role
        event
      end
      let!(:design_event) do
        event = Event.create!(
          title: 'Design Event',
          event_date: 1.day.from_now,
          location: 'Test',
          capacity: 50
        )
        event.organizational_roles << design_role
        event
      end

      it 'returns events for a specific role' do
        expect(Event.for_organizational_role(ai_role)).to include(ai_event)
        expect(Event.for_organizational_role(ai_role)).not_to include(design_event)
      end
    end

    describe 'for_all_roles scope' do
      let(:role) { OrganizationalRole.create!(name: 'AI', description: 'AI Role') }
      let!(:tagged_event) do
        event = Event.create!(
          title: 'Tagged Event',
          event_date: 1.day.from_now,
          location: 'Test',
          capacity: 50,
          is_public: false
        )
        event.organizational_roles << role
        event
      end
      let!(:untagged_event) do
        Event.create!(
          title: 'Untagged Event',
          event_date: 1.day.from_now,
          location: 'Test',
          capacity: 50,
          is_public: false
        )
      end
      let!(:public_event) do
        Event.create!(
          title: 'Public Event',
          event_date: 1.day.from_now,
          location: 'Test',
          capacity: 50,
          is_public: true
        )
      end

      it 'returns events with no roles and not public' do
        expect(Event.for_all_roles).to include(untagged_event)
        expect(Event.for_all_roles).not_to include(tagged_event)
        expect(Event.for_all_roles).not_to include(public_event)
      end
    end

    describe 'visible_to_user scope' do
      let(:ai_role) { OrganizationalRole.create!(name: 'AI', description: 'AI Role') }
      let(:design_role) { OrganizationalRole.create!(name: 'Design', description: 'Design Role') }
      let!(:public_event) do
        Event.create!(
          title: 'Public Event',
          event_date: 1.day.from_now,
          location: 'Test',
          capacity: 50,
          is_public: true
        )
      end
      let!(:ai_event) do
        event = Event.create!(
          title: 'AI Event',
          event_date: 1.day.from_now,
          location: 'Test',
          capacity: 50,
          is_public: false
        )
        event.organizational_roles << ai_role
        event
      end
      let!(:untagged_event) do
        Event.create!(
          title: 'Untagged Event',
          event_date: 1.day.from_now,
          location: 'Test',
          capacity: 50,
          is_public: false
        )
      end

      context 'when user has roles' do
        let(:user_roles) { [ai_role] }

        it 'returns public events, events for user roles, and untagged events' do
          visible = Event.visible_to_user(user_roles)
          expect(visible).to include(public_event)
          expect(visible).to include(ai_event)
          expect(visible).to include(untagged_event)
        end
      end

      context 'when user has no roles' do
        let(:user_roles) { [] }

        it 'returns only public events' do
          visible = Event.visible_to_user(user_roles)
          expect(visible).to include(public_event)
          expect(visible).not_to include(ai_event)
          expect(visible).not_to include(untagged_event)
        end
      end
    end
  end

  describe '#formatted_date' do
    it 'returns formatted date string' do
      event = Event.new(event_date: Time.zone.parse('2025-12-25 14:30:00'))
      expect(event.formatted_date).to eq('December 25, 2025 at 02:30 PM')
    end

    it 'returns nil when event_date is nil' do
      event = Event.new(event_date: nil)
      expect(event.formatted_date).to be_nil
    end
  end

  describe '#upcoming?' do
    it 'returns true for future events' do
      event = Event.new(event_date: 1.day.from_now)
      expect(event.upcoming?).to be true
    end

    it 'returns false for past events' do
      event = Event.new(event_date: 1.day.ago)
      expect(event.upcoming?).to be false
    end
  end
end
