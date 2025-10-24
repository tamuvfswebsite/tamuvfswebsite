require 'rails_helper'

RSpec.describe ApplicationMailer, type: :mailer do
  describe 'default configuration' do
    it 'has the correct default from address' do
      mailer = described_class.default_params
      expect(mailer[:from]).to eq('from@example.com')
    end

    it 'uses the mailer layout' do
      expect(described_class._layout).to eq('mailer')
    end
  end
end
