require 'rails_helper'

RSpec.describe AdminPanel::SponsorsHelper, type: :helper do
  describe 'module inclusion' do
    it 'is included in the helper object' do
      expect(helper.class.ancestors).to include(AdminPanel::SponsorsHelper)
    end
  end
end
