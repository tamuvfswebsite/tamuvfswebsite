class User < ApplicationRecord
  has_one :resume, dependent: :destroy
  validates :google_uid, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
end
