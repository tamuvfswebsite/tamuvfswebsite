require 'rails_helper'

RSpec.describe Translation, type: :model do
  describe 'basic behavior' do
    it 'can be instantiated' do
      translation = Translation.new
      expect(translation).to be_a(Translation)
    end

    it 'is a valid ActiveRecord model' do
      expect(described_class < ApplicationRecord).to be(true)
    end
  end
end
