require 'rails_helper'

RSpec.describe Image, type: :model do
  describe 'basic behavior' do
    it 'can be instantiated' do
      image = Image.new
      expect(image).to be_a(Image)
    end

    it 'is a valid ActiveRecord model' do
      expect(described_class < ApplicationRecord).to be(true)
    end
  end
end
