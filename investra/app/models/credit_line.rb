class CreditLine < ApplicationRecord
  belongs_to :user

  validates :credit_limit, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :credit_used, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
