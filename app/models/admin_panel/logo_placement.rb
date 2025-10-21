module AdminPanel
  class LogoPlacement < ApplicationRecord
    belongs_to :sponsor, class_name: 'Sponsor'
  end
end
