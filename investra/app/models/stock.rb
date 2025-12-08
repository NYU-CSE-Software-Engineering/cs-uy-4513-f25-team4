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
    # Get the most recent price point from yesterday or earlier
    yesterday_price = price_points.where('recorded_at < ?', Time.current.beginning_of_day)
                                   .order(recorded_at: :desc)
                                   .first&.price
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

  # Logistic Regression-based Price Prediction
  def predict_price_with_logistic_regression
    history = price_points.order(recorded_at: :asc)
    
    # Need at least 7 days of data for meaningful prediction
    return nil if history.count < 7
    
    # Calculate daily returns
    returns = calculate_daily_returns(history)
    return nil if returns.empty?
    
    # Extract features: recent returns, moving averages, volatility
    features = extract_features(history, returns)
    
    # Calculate probability of price going up using logistic function
    prob_up = logistic_prediction(features)
    
    # Calculate predicted price based on probability and historical patterns
    avg_up_return = returns.select { |r| r > 0 }.sum / [returns.select { |r| r > 0 }.count, 1].max
    avg_down_return = returns.select { |r| r < 0 }.sum / [returns.select { |r| r < 0 }.count, 1].max
    
    expected_return = (prob_up * avg_up_return) + ((1 - prob_up) * avg_down_return)
    predicted_price = price * (1 + expected_return)
    
    # Calculate confidence based on data quality and consistency
    confidence = calculate_confidence(returns, prob_up, history.count)
    
    {
      predicted_price: predicted_price.round(2),
      probability_up: (prob_up * 100).round(2),
      confidence: (confidence * 100).round(2),
      trend: prob_up > 0.5 ? 'upward' : 'downward',
      data_points: history.count
    }
  end
  
  private
  
  def calculate_daily_returns(history)
    returns = []
    history.each_cons(2) do |prev, curr|
      return_rate = (curr.price - prev.price) / prev.price
      returns << return_rate
    end
    returns
  end
  
  def extract_features(history, returns)
    recent_returns = returns.last(5)
    
    {
      avg_return: returns.sum / returns.count,
      recent_avg: recent_returns.sum / recent_returns.count,
      volatility: calculate_volatility(returns),
      momentum: recent_returns.last(3).sum,
      trend_strength: calculate_trend_strength(returns)
    }
  end
  
  def calculate_volatility(returns)
    mean = returns.sum / returns.count
    variance = returns.map { |r| (r - mean) ** 2 }.sum / returns.count
    Math.sqrt(variance)
  end
  
  def calculate_trend_strength(returns)
    # Count consecutive positive or negative returns
    positive_streak = 0
    negative_streak = 0
    
    returns.reverse.each do |r|
      if r > 0
        positive_streak += 1
        break if negative_streak > 0
      elsif r < 0
        negative_streak += 1
        break if positive_streak > 0
      end
    end
    
    positive_streak - negative_streak
  end
  
  def logistic_prediction(features)
    # Simplified logistic regression weights (trained conceptually)
    # These weights favor recent performance and momentum
    z = 0.5 + # Base probability
        (features[:avg_return] * 30) + # Overall trend
        (features[:recent_avg] * 50) + # Recent trend (weighted higher)
        (features[:momentum] * 20) + # Short-term momentum
        (features[:trend_strength] * 0.05) # Consistency bonus
    
    # Sigmoid function: 1 / (1 + e^(-z))
    1.0 / (1.0 + Math.exp(-z))
  end
  
  def calculate_confidence(returns, prob_up, data_count)
    # Confidence based on:
    # 1. Amount of data (more data = higher confidence)
    # 2. Consistency of returns (lower volatility = higher confidence)
    # 3. Strength of prediction (extreme probabilities = higher confidence)
    
    data_confidence = [data_count / 30.0, 1.0].min # Max at 30 days
    volatility = calculate_volatility(returns)
    consistency_confidence = 1.0 / (1.0 + volatility * 10) # Lower volatility = higher confidence
    prediction_strength = (prob_up - 0.5).abs * 2 # 0.5 to 1.0 scale
    
    # Weighted average
    (data_confidence * 0.3 + consistency_confidence * 0.4 + prediction_strength * 0.3)
  end
end

