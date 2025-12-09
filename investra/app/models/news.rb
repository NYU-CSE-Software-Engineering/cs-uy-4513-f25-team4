class News < ApplicationRecord
  belongs_to :stock

  validates :title, presence: true
  validates :stock, presence: true
  validates :published_at, presence: true

  scope :recent, -> { order(published_at: :desc) }
  scope :for_stock, ->(stock) { where(stock: stock) }
  
  # Get recent news for a specific stock
  def self.recent_for_stock(stock, limit: 10)
    where(stock: stock).order(published_at: :desc).limit(limit)
  end
end

