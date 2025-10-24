require 'rails_helper'

RSpec.describe AdminPanel::DashboardHelper, type: :helper do
  describe 'module inclusion' do
    it 'is included in the helper object' do
      expect(helper.class.ancestors).to include(AdminPanel::DashboardHelper)
    end
  end
end
