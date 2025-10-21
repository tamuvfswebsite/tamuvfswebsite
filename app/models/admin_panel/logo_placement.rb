class AdminPanel::LogoPlacement < ApplicationRecord
  belongs_to :sponsor, class_name: "Sponsor"
end
