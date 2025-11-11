require 'rails_helper'

RSpec.describe AdminPanel::SponsorUserAssigner do
  let(:default_sponsor) { Sponsor.create!(company_name: 'Unassigned Sponsor', website: 'https://default.com') }
  let(:sponsor) { Sponsor.create!(company_name: 'Tech Corp', website: 'https://techcorp.com') }
  let(:other_sponsor) { Sponsor.create!(company_name: 'Other Corp', website: 'https://othercorp.com') }

  let(:sponsor_user1) do
    User.create!(
      email: 'sponsor1@example.com',
      first_name: 'Sponsor',
      last_name: 'One',
      google_uid: '123',
      role: 'sponsor'
    )
  end

  let(:sponsor_user2) do
    User.create!(
      email: 'sponsor2@example.com',
      first_name: 'Sponsor',
      last_name: 'Two',
      google_uid: '456',
      role: 'sponsor'
    )
  end

  let(:student_user) do
    User.create!(
      email: 'student@example.com',
      first_name: 'Student',
      last_name: 'User',
      google_uid: '789',
      role: 'student'
    )
  end

  before do
    allow(Sponsor).to receive(:default_sponsor).and_return(default_sponsor)
    # Ensure users start with no sponsors
    sponsor_user1.sponsors.clear
    sponsor_user2.sponsors.clear
  end

  describe '#call' do
    context 'when assigning users to a sponsor' do
      it 'assigns selected users to the sponsor' do
        assigner = described_class.new(sponsor, [sponsor_user1.id, sponsor_user2.id])
        assigner.call

        sponsor.reload
        expect(sponsor.users).to include(sponsor_user1, sponsor_user2)
      end

      it 'clears previous assignments for assigned users' do
        # Assign user1 to other_sponsor first
        sponsor_user1.sponsors << other_sponsor

        assigner = described_class.new(sponsor, [sponsor_user1.id])
        assigner.call

        sponsor_user1.reload
        expect(sponsor_user1.sponsors).to eq([sponsor])
        expect(sponsor_user1.sponsors).not_to include(other_sponsor)
      end

      it 'only assigns users with sponsor role' do
        assigner = described_class.new(sponsor, [sponsor_user1.id, student_user.id])
        assigner.call

        sponsor.reload
        expect(sponsor.users).to include(sponsor_user1)
        expect(sponsor.users).not_to include(student_user)
      end

      it 'handles string IDs' do
        assigner = described_class.new(sponsor, [sponsor_user1.id.to_s, sponsor_user2.id.to_s])
        assigner.call

        sponsor.reload
        expect(sponsor.users).to include(sponsor_user1, sponsor_user2)
      end

      it 'filters out blank values' do
        assigner = described_class.new(sponsor, [sponsor_user1.id, '', nil, sponsor_user2.id])
        assigner.call

        sponsor.reload
        expect(sponsor.users).to include(sponsor_user1, sponsor_user2)
      end
    end

    context 'when removing users from a sponsor' do
      it 'reassigns removed users to default sponsor' do
        # Initially assign both users to sponsor
        sponsor_user1.sponsors << sponsor
        sponsor_user2.sponsors << sponsor

        # Now only assign user2, user1 should go to default
        assigner = described_class.new(sponsor, [sponsor_user2.id])
        assigner.call

        sponsor_user1.reload
        sponsor_user2.reload

        expect(sponsor_user1.sponsors).to eq([default_sponsor])
        expect(sponsor_user2.sponsors).to eq([sponsor])
      end
    end

    context 'when assigning unassigned users to default sponsor' do
      it 'assigns unassigned sponsor users to default sponsor' do
        sponsor_user1.sponsors << sponsor
        # sponsor_user2 has no sponsors

        assigner = described_class.new(sponsor, [sponsor_user1.id])
        assigner.call

        sponsor_user2.reload
        expect(sponsor_user2.sponsors).to include(default_sponsor)
      end

      it 'does not reassign already assigned users to default sponsor' do
        sponsor_user1.sponsors << sponsor
        sponsor_user2.sponsors << other_sponsor

        assigner = described_class.new(sponsor, [sponsor_user1.id])
        assigner.call

        sponsor_user1.reload
        sponsor_user2.reload
        expect(sponsor_user1.sponsors).to eq([sponsor])
        expect(sponsor_user2.sponsors).to eq([other_sponsor])
      end

      it 'does not assign non-sponsor role users to default sponsor' do
        assigner = described_class.new(sponsor, [sponsor_user1.id])
        assigner.call

        student_user.reload
        expect(student_user.sponsors).to be_empty
      end
    end

    context 'with empty user_ids' do
      it 'clears all existing assignments and assigns removed users to default' do
        sponsor_user1.sponsors << sponsor
        sponsor_user2.sponsors << sponsor

        assigner = described_class.new(sponsor, [])
        assigner.call

        sponsor_user1.reload
        sponsor_user2.reload

        # Both users were removed from sponsor, so both should go to default
        expect(sponsor_user1.sponsors).to eq([default_sponsor])
        expect(sponsor_user2.sponsors).to eq([default_sponsor])
      end
    end

    context 'with nil user_ids' do
      it 'handles nil user_ids gracefully' do
        sponsor_user1.sponsors << sponsor

        assigner = described_class.new(sponsor, nil)

        expect { assigner.call }.not_to raise_error

        sponsor_user1.reload
        expect(sponsor_user1.sponsors).to eq([default_sponsor])
      end
    end

    context 'transaction rollback' do
      it 'rolls back all changes if an error occurs' do
        sponsor_user1.sponsors << sponsor
        initial_sponsors = sponsor_user1.sponsors.to_a

        # Force an error during the transaction by stubbing a method
        allow_any_instance_of(described_class).to receive(:assign_selected_users).and_raise(StandardError, 'Test error')

        assigner = described_class.new(sponsor, [sponsor_user2.id])

        expect { assigner.call }.to raise_error(StandardError, 'Test error')

        sponsor_user1.reload
        # Should still have original sponsor assignment
        expect(sponsor_user1.sponsors.to_a).to eq(initial_sponsors)
      end
    end

    context 'with non-existent user IDs' do
      it 'ignores non-existent user IDs' do
        non_existent_id = User.maximum(:id).to_i + 1

        assigner = described_class.new(sponsor, [sponsor_user1.id, non_existent_id])
        assigner.call

        sponsor.reload
        expect(sponsor.users).to include(sponsor_user1)
        expect(sponsor.users.count).to eq(1)
      end
    end

    context 'complex scenario' do
      it 'correctly handles reassigning users between multiple sponsors' do
        # Setup: user1 on sponsor, user2 on other_sponsor
        sponsor_user1.sponsors << sponsor
        sponsor_user2.sponsors << other_sponsor

        # Action: Swap them - user2 goes to sponsor, user1 should go to default
        assigner = described_class.new(sponsor, [sponsor_user2.id])
        assigner.call

        sponsor_user1.reload
        sponsor_user2.reload

        expect(sponsor_user1.sponsors).to eq([default_sponsor])
        expect(sponsor_user2.sponsors).to eq([sponsor])
      end
    end
  end
end
