class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :stock

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :transaction_type, presence: true, inclusion: { in: %w[buy sell] }
  validates :price, presence: true, numericality: { greater_than: 0 }

  scope :buy, -> { where(transaction_type: 'buy') }
  scope :sell, -> { where(transaction_type: 'sell') }
end

