require 'rails_helper'

RSpec.describe AdminPanel::DesignUpdatesHelper, type: :helper do
  describe 'module inclusion' do
    it 'is included in the helper object' do
      expect(helper.class.ancestors).to include(AdminPanel::DesignUpdatesHelper)
    end
  end
end
