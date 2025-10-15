class Sponsor < ApplicationRecord
  has_many :sponsor_user_joins
  has_many :users, through: :sponsor_user_joins
end
