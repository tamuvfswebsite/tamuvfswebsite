require 'rails_helper'

RSpec.describe Sponsor, type: :model do
  describe 'validations' do
    it 'is invalid without a company_name' do
      sponsor = Sponsor.new(company_name: nil)
      expect(sponsor).not_to be_valid
      expect(sponsor.errors[:company_name]).to include("can't be blank")
    end

    it 'is invalid with a duplicate company_name' do
      Sponsor.create!(company_name: 'TechCorp')
      duplicate = Sponsor.new(company_name: 'TechCorp')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:company_name]).to include('has already been taken')
    end
  end

  describe 'associations' do
    it 'has many sponsor_user_joins' do
      association = Sponsor.reflect_on_association(:sponsor_user_joins)
      expect(association.macro).to eq(:has_many)
    end

    it 'has many users through sponsor_user_joins' do
      association = Sponsor.reflect_on_association(:users)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:through]).to eq(:sponsor_user_joins)
    end

    it 'has many logo_placements with correct class and dependent destroy' do
      association = Sponsor.reflect_on_association(:logo_placements)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:class_name]).to eq('AdminPanel::LogoPlacement')
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end
end
