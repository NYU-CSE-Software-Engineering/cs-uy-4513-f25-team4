require "net/http"
require "json"
require "timeout"

module MarketData
  class YahooClient
    BASE_URL = "https://query1.finance.yahoo.com/v7/finance/quote".freeze
    CHART_URL = "https://query1.finance.yahoo.com/v8/finance/chart".freeze
    TIMEOUT_SECONDS = 5
    MAX_RETRIES = 2
    RETRY_DELAY = 1 # seconds
    
    # Use mock data if USE_MOCK_DATA env var is set to 'true' or in test environment
    USE_MOCK_DATA = ENV.fetch("USE_MOCK_DATA", "false").downcase == "true" || Rails.env.test?

    def fetch_quote(ticker)
      return { error: "Missing ticker" } if ticker.to_s.strip.empty?
      
      return mock_quote(ticker) if USE_MOCK_DATA
      return { error: "Missing ticker" } if ticker.to_s.strip.empty?

      # Cache quotes for 15 minutes
      Rails.cache.fetch(cache_key(ticker), expires_in: 15.minutes) do
        # Small delay to avoid hitting rate limits
        sleep(0.5)
        
        uri = URI(BASE_URL)
        uri.query = URI.encode_www_form(symbols: ticker)

        response = perform_request_with_retry(uri)
        return response if response[:error]

        parse_body(response[:body], ticker)
      end
    rescue StandardError => e
      { error: "Lookup failed: #{e.message}" }
    end

    # Fetch historical price data for a stock
    # range options: "1d", "5d", "1mo", "3mo", "6mo", "1y", "2y", "5y", "10y", "ytd", "max"
    # interval options: "1m", "2m", "5m", "15m", "30m", "60m", "90m", "1h", "1d", "5d", "1wk", "1mo", "3mo"
    def fetch_historical_data(ticker, range: "1y", interval: "1d")
      return { error: "Missing ticker" } if ticker.to_s.strip.empty?
      
      return mock_historical_data(ticker, range, interval) if USE_MOCK_DATA

      cache_key = "market_data:historical:#{ticker.upcase}:#{range}:#{interval}"
      # Cache historical data for 2 hours since it doesn't change
      Rails.cache.fetch(cache_key, expires_in: 2.hours) do
        # Small delay to avoid hitting rate limits
        sleep(1)
        
        uri = URI("#{CHART_URL}/#{ticker.upcase}")
        params = {
          interval: interval,
          range: range,
          includePrePost: false,
          events: "div,splits"
        }
        uri.query = URI.encode_www_form(params)

        response = perform_request_with_retry(uri)
        return response if response[:error]

        parse_historical_data(response[:body], ticker)
      end
    rescue StandardError => e
      { error: "Historical data lookup failed: #{e.message}" }
    end

    # Fetch price at a specific date (for what-if simulations)
    def fetch_price_at_date(ticker, date)
      return { error: "Missing ticker" } if ticker.to_s.strip.empty?
      return { error: "Invalid date" } unless date.is_a?(Date) || date.is_a?(Time)

      target_timestamp = date.to_time.to_i
      end_date = [date, Date.today].min
      
      # Fetch data from the date to today
      days_diff = (Date.today - end_date).to_i
      range = case days_diff
              when 0..5 then "5d"
              when 6..30 then "1mo"
              when 31..90 then "3mo"
              when 91..180 then "6mo"
              when 181..365 then "1y"
              else "2y"
              end

      historical_data = fetch_historical_data(ticker, range: range, interval: "1d")
      return historical_data if historical_data[:error]

      timestamps = historical_data[:timestamps] || []
      prices = historical_data[:prices] || []
      
      return { error: "No data available" } if timestamps.empty?

      # Find the closest timestamp to the target date
      # If target is before all data, use first available
      if timestamps.first && timestamps.first > target_timestamp
        closest_index = 0
      else
        # Find first timestamp >= target, or use last if all are before
        closest_index = timestamps.find_index { |ts| ts >= target_timestamp }
        closest_index ||= timestamps.length - 1
      end

      return { error: "No price data for date" } if closest_index.nil? || prices[closest_index].nil?

      {
        price: prices[closest_index],
        date: Time.at(timestamps[closest_index]).to_date,
        timestamp: timestamps[closest_index]
      }
    end

    private

    def perform_request(uri)
      Timeout.timeout(TIMEOUT_SECONDS + 2) do
        Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: TIMEOUT_SECONDS, open_timeout: TIMEOUT_SECONDS) do |http|
          http.get(uri.request_uri)
        end
      end
    rescue Timeout::Error
      raise Net::ReadTimeout.new("Request timed out after #{TIMEOUT_SECONDS + 2} seconds")
    end

    def perform_request_with_retry(uri, retries = MAX_RETRIES)
      attempt = 0
      
      begin
        loop do
          attempt += 1
          
          # Safety check to prevent infinite loops
          if attempt > retries + 1
            return { error: "Maximum retry attempts exceeded. Please try again later." }
          end
          
          begin
            response = perform_request(uri)
            
            # Handle nil response
            unless response
              return { error: "No response received from Yahoo Finance API" }
            end
            
            case response
            when Net::HTTPSuccess
              return { body: response.body }
            when Net::HTTPTooManyRequests
              if attempt <= retries
                delay = RETRY_DELAY * (2 ** (attempt - 1)) # Exponential backoff
                sleep(delay)
                next # Retry the loop
              else
                return { error: "Rate limit exceeded. Please wait a few minutes and try again. Yahoo Finance API is temporarily limiting requests." }
              end
            when Net::HTTPClientError, Net::HTTPServerError
              return { error: format_error_message(response.code, response.message) }
            else
              # Handle any other response type
              return { error: "Request failed with status #{response.code}" }
            end
          rescue Net::ReadTimeout, Net::OpenTimeout => e
            if attempt <= retries
              sleep(RETRY_DELAY * attempt)
              next # Retry the loop
            else
              return { error: "Request timed out. Please try again later." }
            end
          rescue StandardError => e
            # On first attempt, retry for network errors. Otherwise, return error.
            if attempt <= retries && e.message.include?("Network")
              sleep(RETRY_DELAY)
              next
            else
              return { error: "Network error: #{e.message}" }
            end
          end
        end
      rescue StandardError => e
        # Final safety net
        { error: "Unexpected error: #{e.message}" }
      end
    end

    def format_error_message(code, message)
      case code.to_i
      when 429
        "Rate limit exceeded. Yahoo Finance API is temporarily limiting requests. Please wait a few minutes and try again."
      when 404
        "Stock data not found. Please check the ticker symbol."
      when 403
        "Access forbidden. Yahoo Finance API may be blocking requests."
      when 500..599
        "Yahoo Finance API is temporarily unavailable. Please try again later."
      else
        "Request failed with status #{code}: #{message}"
      end
    end

    def parse_body(body, ticker)
      data = JSON.parse(body)
      quote = data.dig("quoteResponse", "result")&.first
      return { error: "No data for #{ticker}" } unless quote

      {
        name: quote["shortName"] || quote["longName"],
        ticker: quote["symbol"],
        sector: quote["sector"],
        market_cap: quote["marketCap"],
        price: quote["regularMarketPrice"],
        currency: quote["currency"],
        exchange: quote["fullExchangeName"],
        fetched_at: Time.current
      }
    rescue JSON::ParserError
      { error: "Unexpected response format" }
    end

    def parse_historical_data(body, ticker)
      data = JSON.parse(body)
      result = data.dig("chart", "result")&.first
      return { error: "No historical data for #{ticker}" } unless result

      timestamps = result["timestamp"] || []
      indicators = result.dig("indicators", "quote")&.first || {}
      closes = indicators["close"] || []
      opens = indicators["open"] || []
      highs = indicators["high"] || []
      lows = indicators["low"] || []
      volumes = indicators["volume"] || []

      # Build array of price data points
      price_data = timestamps.map.with_index do |timestamp, index|
        {
          timestamp: timestamp,
          date: Time.at(timestamp).to_date,
          open: opens[index],
          high: highs[index],
          low: lows[index],
          close: closes[index],
          volume: volumes[index]
        }
      end

      {
        ticker: ticker.upcase,
        timestamps: timestamps,
        prices: closes,
        price_data: price_data,
        meta: result["meta"] || {}
      }
    rescue JSON::ParserError
      { error: "Unexpected response format" }
    end

    def cache_key(ticker)
      "market_data:quote:#{ticker.upcase}"
    end

    # Mock data methods for development/testing
    def mock_quote(ticker)
      # Generate realistic mock data based on ticker
      base_prices = {
        "TSLA" => 250.0,
        "AAPL" => 180.0,
        "MSFT" => 420.0,
        "GOOGL" => 140.0,
        "AMZN" => 150.0,
        "META" => 500.0,
        "NVDA" => 800.0
      }
      
      base_price = base_prices[ticker.upcase] || 100.0
      # Add some random variation
      price = base_price + (rand * 20 - 10)
      
      {
        name: "#{ticker.upcase} Inc.",
        ticker: ticker.upcase,
        sector: "Technology",
        market_cap: price * 1_000_000_000,
        price: price.round(2),
        currency: "USD",
        exchange: "NASDAQ",
        fetched_at: Time.current
      }
    end

    def mock_historical_data(ticker, range, interval)
      # Generate realistic historical price data
      base_prices = {
        "TSLA" => 250.0,
        "AAPL" => 180.0,
        "MSFT" => 420.0,
        "GOOGL" => 140.0,
        "AMZN" => 150.0,
        "META" => 500.0,
        "NVDA" => 800.0
      }
      
      base_price = base_prices[ticker.upcase] || 100.0
      
      # Calculate number of data points based on range
      days = case range
             when "5d" then 5
             when "1mo" then 30
             when "3mo" then 90
             when "6mo" then 180
             when "1y" then 365
             when "2y" then 730
             when "5y" then 1825
             when "max" then 1825
             else 365
             end
      
      # Generate timestamps and prices
      now = Time.now.to_i
      timestamps = []
      prices = []
      price_data = []
      
      days.times do |i|
        # Go backwards in time
        timestamp = now - (days - i) * 86400 # 86400 seconds = 1 day
        timestamps << timestamp
        
        # Generate price with trend and random variation
        trend = Math.sin(i * Math::PI / days) * 0.2 # Slight upward trend
        variation = (rand - 0.5) * 0.1 # Random variation
        price = base_price * (1 + trend + variation)
        prices << price.round(2)
        
        price_data << {
          timestamp: timestamp,
          date: Time.at(timestamp).to_date,
          open: (price * (1 + (rand - 0.5) * 0.02)).round(2),
          high: (price * (1 + rand * 0.03)).round(2),
          low: (price * (1 - rand * 0.03)).round(2),
          close: price.round(2),
          volume: (rand * 10_000_000 + 1_000_000).to_i
        }
      end
      
      {
        ticker: ticker.upcase,
        timestamps: timestamps,
        prices: prices,
        price_data: price_data,
        meta: {
          currency: "USD",
          exchange: "NASDAQ",
          symbol: ticker.upcase
        }
      }
    end
  end
end
