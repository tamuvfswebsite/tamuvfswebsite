class User < ApplicationRecord
  validates :google_uid, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
end
