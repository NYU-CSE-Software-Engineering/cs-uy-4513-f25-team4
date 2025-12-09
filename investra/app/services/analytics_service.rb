class AnalyticsService
  def initialize(user, market_client: nil)
    @user = user
    massive_key = ENV.fetch("MASSIVE_API_KEY", "").strip
    use_massive = massive_key.present? && !MarketData::YahooClient::USE_MOCK_DATA
    @client = market_client || (use_massive ? MarketData::MassiveClient.new(api_key: massive_key) : MarketData::YahooClient.new)
  end

  # Calculate what-if investment simulation
  # Returns: { current_value, roi_percent, profit_loss, error }
  def simulate_investment(ticker, amount, start_date)
    return { error: "Ticker symbol is required" } if ticker.to_s.strip.empty?
    return { error: "Investment amount must be greater than 0" } if amount.to_f <= 0
    return { error: "Start date is required" } unless start_date

    begin
      start_date = Date.parse(start_date.to_s) if start_date.is_a?(String)
    rescue ArgumentError
      return { error: "Invalid date format" }
    end

    return { error: "Start date cannot be in the future" } if start_date > Date.today

    # Fetch price at start date
    start_price_data = @client.fetch_price_at_date(ticker, start_date)
    return start_price_data if start_price_data[:error]

    start_price = start_price_data[:price]
    return { error: "Could not fetch price for #{ticker} at #{start_date}" } unless start_price && start_price > 0

    # Fetch current price
    current_quote = @client.fetch_quote(ticker)
    return current_quote if current_quote[:error]

    current_price = current_quote[:price]
    return { error: "Could not fetch current price for #{ticker}" } unless current_price && current_price > 0

    # Calculate shares purchased
    shares = amount / start_price

    # Calculate current value
    current_value = shares * current_price

    # Calculate ROI and profit/loss
    profit_loss = current_value - amount
    roi_percent = ((current_value - amount) / amount) * 100

    {
      ticker: ticker.upcase,
      investment_amount: amount,
      start_date: start_date,
      start_price: start_price.round(2),
      shares: shares.round(4),
      current_price: current_price.round(2),
      current_value: current_value.round(2),
      profit_loss: profit_loss.round(2),
      roi_percent: roi_percent.round(2),
      stock_name: current_quote[:name]
    }
  end
end

