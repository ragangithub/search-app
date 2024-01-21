class Search < ApplicationRecord

  validates :query, presence: true, length: { minimum: 3, maximum: 60 }
  belongs_to :user

  scope :in_descending_order_by, -> (user) { where(user: user).order(created_at: :desc) }
end
