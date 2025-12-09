class PricePoint < ApplicationRecord
  belongs_to :stock

  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :recorded_at, presence: true
  validates :stock, presence: true

  scope :recent, -> { order(recorded_at: :desc) }
  scope :for_date_range, ->(start_date, end_date) { where(recorded_at: start_date..end_date) }

  # Get price points for a specific stock in date range
  def self.for_stock_in_range(stock, days = 30)
    where(stock: stock)
      .where('recorded_at >= ?', days.days.ago)
      .order(recorded_at: :desc)
  end

  # Calculate statistics for price points
  def self.statistics
    {
      high: maximum(:price),
      low: minimum(:price),
      average: average(:price)&.to_f&.round(2)
    }
  end
end

