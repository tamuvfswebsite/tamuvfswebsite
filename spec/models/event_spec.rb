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
