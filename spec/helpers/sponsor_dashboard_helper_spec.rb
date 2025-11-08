require 'rails_helper'

RSpec.describe SponsorDashboardHelper, type: :helper do
  describe 'module inclusion' do
    it 'is included in the helper object' do
      expect(helper.class.ancestors).to include(SponsorDashboardHelper)
    end
  end
end
