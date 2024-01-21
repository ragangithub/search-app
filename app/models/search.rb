class Search < ApplicationRecord

  validates :query, presence: true, length: { minimum: 3, maximum: 60 }
  belongs_to :user

  scope :order_by, -> (user) { where(user: user).order(created_at: :desc) }
end
