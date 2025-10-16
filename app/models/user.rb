class User < ApplicationRecord
  has_one :resume, dependent: :destroy
  belongs_to :organizational_role, optional: true

  validates :google_uid, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
end
