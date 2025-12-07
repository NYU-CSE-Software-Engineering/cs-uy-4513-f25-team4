class Stock < ApplicationRecord
  has_many :portfolios, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :news, dependent: :destroy

  validates :symbol, presence: true, uniqueness: true
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :available_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Get recent news for this stock
  def recent_news(limit: 10)
    news.order(published_at: :desc).limit(limit)
  end
end

