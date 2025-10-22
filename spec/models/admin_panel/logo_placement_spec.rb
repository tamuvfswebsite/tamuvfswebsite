require 'rails_helper'

RSpec.describe AdminPanel::LogoPlacement, type: :model do
  describe 'associations' do
    it 'belongs to sponsor' do
      association = described_class.reflect_on_association(:sponsor)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq('Sponsor')
    end
  end
end
