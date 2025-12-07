class Stock < ApplicationRecord
  has_many :portfolios, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :news, dependent: :destroy
  has_many :price_points, dependent: :destroy

  validates :symbol, presence: true, uniqueness: true
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :available_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :market_cap, numericality: { greater_than: 0, allow_nil: true }
  
  # Get recent news for this stock
  def recent_news(limit: 10)
    news.order(published_at: :desc).limit(limit)
  end

  # Get recent price history
  def recent_price_history(days = 30)
    price_points.where('recorded_at >= ?', days.days.ago).order(recorded_at: :desc)
  end

  # Get price statistics for last N days
  def price_statistics(days = 30)
    points = price_points.where('recorded_at >= ?', days.days.ago)
    {
      high: points.maximum(:price),
      low: points.minimum(:price),
      average: points.average(:price)&.to_f&.round(2)
    }
  end

  # Calculate price change from yesterday
  def price_change
    yesterday_price = price_points.where('recorded_at >= ? AND recorded_at < ?', 
      1.day.ago.beginning_of_day, 1.day.ago.end_of_day).last&.price
    return nil unless yesterday_price
    
    change_amount = price - yesterday_price
    change_percentage = ((change_amount / yesterday_price) * 100).round(2)
    
    {
      amount: change_amount.round(2),
      percentage: change_percentage,
      direction: change_amount >= 0 ? 'positive' : 'negative'
    }
  end

  # Get the last updated time in human-readable format
  def last_updated_human
    distance_in_minutes = ((Time.now - updated_at) / 60).round
    
    case distance_in_minutes
    when 0..1
      "1 minute ago"
    when 2..44
      "#{distance_in_minutes} minutes ago"
    when 45..89
      "1 hour ago"
    when 90..1439
      "#{(distance_in_minutes / 60).round} hours ago"
    when 1440..2519
      "1 day ago"
    else
      "#{(distance_in_minutes / 1440).round} days ago"
    end
  end
end

