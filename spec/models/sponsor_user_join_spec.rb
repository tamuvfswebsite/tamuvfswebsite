require 'rails_helper'

RSpec.describe SponsorUserJoin, type: :model do
  let(:sponsor_user) do
    User.create!(
      google_uid: SecureRandom.uuid,
      email: 'sponsor@example.com',
      role: 'sponsor'
    )
  end
  let(:regular_user) do
    User.create!(
      google_uid: SecureRandom.uuid,
      email: 'user@example.com',
      role: 'member'
    )
  end
  let(:sponsor) { Sponsor.create!(company_name: 'Test Sponsor') }

  it 'is valid when user has sponsor role' do
    join = SponsorUserJoin.new(user: sponsor_user, sponsor: sponsor)
    expect(join).to be_valid
  end

  it 'is invalid when user does not have sponsor role' do
    join = SponsorUserJoin.new(user: regular_user, sponsor: sponsor)
    expect(join).not_to be_valid
    expect(join.errors[:user]).to include("must have role 'sponsor'")
  end

  it 'belongs to user' do
    expect(SponsorUserJoin.reflect_on_association(:user).macro).to eq(:belongs_to)
  end

  it 'belongs to sponsor' do
    expect(SponsorUserJoin.reflect_on_association(:sponsor).macro).to eq(:belongs_to)
  end
end
