class Portfolio < ApplicationRecord
  belongs_to :user
  belongs_to :stock

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :stock_id, uniqueness: { scope: :user_id, message: 'has already been taken' }
end

