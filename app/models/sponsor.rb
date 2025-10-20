class Sponsor < ApplicationRecord
  validates :company_name, presence: true, uniqueness: true
  has_many :sponsor_user_joins
  has_many :users, through: :sponsor_user_joins
end
