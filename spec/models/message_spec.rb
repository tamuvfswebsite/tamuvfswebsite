require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'basic behavior' do
    it 'can be instantiated' do
      message = Message.new
      expect(message).to be_a(Message)
    end

    it 'is a valid ActiveRecord model' do
      expect(described_class < ApplicationRecord).to be(true)
    end
  end
end
