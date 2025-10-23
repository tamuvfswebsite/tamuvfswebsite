require 'rails_helper'

RSpec.describe ApplicationJob, type: :job do
  describe 'basic behavior' do
    it 'inherits from ActiveJob::Base' do
      expect(described_class < ActiveJob::Base).to be(true)
    end

    it 'can be instantiated' do
      job = described_class.new
      expect(job).to be_a(ApplicationJob)
    end
  end
end
