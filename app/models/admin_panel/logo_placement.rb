module AdminPanel
  class LogoPlacement < ApplicationRecord
    belongs_to :sponsor, class_name: 'Sponsor'

    validates :page_name, presence: true
    validates :section, presence: true
    validates :displayed, inclusion: { in: [true, false] }
  end
end
