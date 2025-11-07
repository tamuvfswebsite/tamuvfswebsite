require 'rails_helper'

RSpec.describe Admins::SessionsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:admin]
  end

  describe '#after_sign_out_path_for' do
    it 'returns root_path after sign out' do
      expect(controller.after_sign_out_path_for(nil)).to eq(root_path)
    end
  end

  describe '#after_sign_in_path_for' do
    it 'returns root_path when no stored location' do
      admin = double('Admin')
      allow(controller).to receive(:stored_location_for).with(admin).and_return(nil)

      expect(controller.after_sign_in_path_for(admin)).to eq(root_path)
    end

    it 'returns stored location when available' do
      admin = double('Admin')
      stored_path = '/some/stored/path'
      allow(controller).to receive(:stored_location_for).with(admin).and_return(stored_path)

      expect(controller.after_sign_in_path_for(admin)).to eq(stored_path)
    end
  end
end
