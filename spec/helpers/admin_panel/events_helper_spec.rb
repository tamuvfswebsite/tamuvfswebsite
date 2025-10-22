require 'rails_helper'

RSpec.describe AdminPanel::EventsHelper, type: :helper do
  describe 'module inclusion' do
    it 'is included in the helper object' do
      expect(helper.class.ancestors).to include(AdminPanel::EventsHelper)
    end
  end
end
