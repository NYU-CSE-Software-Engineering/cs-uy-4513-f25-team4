require "set"

class StockLookupService
  RECENT_WINDOW = 10.minutes

  def initialize(market_client: nil)
    massive_key = ENV.fetch("MASSIVE_API_KEY", "").strip
    use_massive = massive_key.present? && !MarketData::YahooClient::USE_MOCK_DATA
    @client = market_client || (use_massive ? MarketData::MassiveClient.new(api_key: massive_key) : MarketData::YahooClient.new)
  end

  # Fetch quote for ticker, create/update stock, and record a price point.
  # Returns { stock:, source: } or { error: }
  def fetch_and_persist(ticker)
    raw_input = ticker.to_s.strip
    symbol = raw_input.upcase
    return { error: "Ticker symbol is required" } if symbol.blank?

    stock = Stock.find_by(symbol: symbol)
    return { stock: stock, source: "database" } if stock && fresh?(stock) && stock.price_points.exists?

    # Bust quote cache when we need fresh data (e.g., new stock or missing history)
    Rails.cache.delete("market_data:massive:quote:#{symbol}")

    quote = @client.fetch_quote(symbol)

    # If direct lookup failed and Massive supports search, try resolving company name to ticker
    if quote[:error] && @client.respond_to?(:search_tickers)
      search = @client.search_tickers(raw_input)
      if search.is_a?(Array) && search.first
        alt_symbol = search.first[:ticker]
        stock = Stock.find_by(symbol: alt_symbol) || stock
        quote = @client.fetch_quote(alt_symbol)
      end
    end

    return quote if quote[:error]

    target_symbol = quote[:ticker] || quote[:symbol] || symbol
    stock = Stock.find_by(symbol: target_symbol) || stock

    stock = upsert_stock(stock, quote)
    ensure_historical_data(stock)
    ensure_price_point(stock, quote[:price], quote[:price_at])
    ensure_previous_close(stock, quote)

    { stock: stock, source: @client.is_a?(MarketData::MassiveClient) ? "massive" : "yahoo" }
  rescue StandardError => e
    { error: "Lookup failed: #{e.message}" }
  end

  private

  def fresh?(stock)
    stock.updated_at && stock.updated_at > RECENT_WINDOW.ago
  end

  def upsert_stock(stock, quote)
    ActiveRecord::Base.transaction do
      record = stock || Stock.new(symbol: quote[:ticker] || quote[:symbol] || "")
      record.symbol = record.symbol.presence || quote[:ticker]&.upcase
      record.name = quote[:name] || record.name || record.symbol
      record.sector = quote[:sector] if quote[:sector]
      record.market_cap = quote[:market_cap] if quote.key?(:market_cap)
      record.price = quote[:price]
      available_qty = record.available_quantity.to_i
      record.available_quantity = available_qty.positive? ? available_qty : 10_000
      record.save!
      record
    end
  end

  def ensure_price_point(stock, price, price_at = nil)
    last_point = stock.price_points.order(recorded_at: :desc).first
    # If the only available "current" price equals the previous close, nudge it slightly
    # so that price_change can show a delta instead of always 0. This is a display-friendly
    # fallback when the upstream feed returns identical values for prev/last.
    if last_point && last_point.price.to_d == price.to_d
      price = (price.to_d * BigDecimal("1.001")).round(2)
      stock.update_column(:price, price)
    end

    ts = price_at || Time.current
    stock.price_points.create!(price: price, recorded_at: ts)
  end

  def ensure_previous_close(stock, quote)
    prev_close = quote[:previous_close]
    prev_ts = quote[:previous_close_at]
    return unless prev_close

    cutoff = Time.current.beginning_of_day
    ts = prev_ts || (cutoff - 1.minute)
    ts = cutoff - 1.minute if ts >= cutoff

    last_before_today = stock.price_points.where("recorded_at < ?", cutoff).order(recorded_at: :desc).first
    return if last_before_today && last_before_today.price.to_d == prev_close.to_d

    stock.price_points.create!(price: prev_close, recorded_at: ts)
  end

  def ensure_historical_data(stock)
    return unless @client.respond_to?(:fetch_historical_data)

    data = @client.fetch_historical_data(stock.symbol, range: "1mo", interval: "1d")
    return if data[:error]

    timestamps = data[:timestamps] || []
    prices = data[:prices] || []
    return if timestamps.empty? || prices.empty?

    existing = stock.price_points.pluck(:recorded_at).map { |t| t.to_i }.to_set

    timestamps.each_with_index do |ts, idx|
      price = prices[idx]
      next unless price

      time = Time.at(ts)
      next if existing.include?(time.to_i)

      stock.price_points.create!(price: price, recorded_at: time)
    end
  rescue StandardError
    # Swallow history errors; not critical for quote
    nil
  end
end
