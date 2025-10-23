require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'basic behavior' do
    it 'can be instantiated' do
      payment = Payment.new
      expect(payment).to be_a(Payment)
    end

    it 'is a valid ActiveRecord model' do
      expect(described_class < ApplicationRecord).to be(true)
    end
  end
end
