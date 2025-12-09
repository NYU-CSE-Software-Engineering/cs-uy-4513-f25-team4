require "net/http"
require "json"
require "cgi"

module MarketData
  class MassiveClient
    BASE_URL = ENV.fetch("MASSIVE_API_BASE", "https://api.massive.com").freeze
    TIMEOUT_SECONDS = 5

    def initialize(api_key: ENV.fetch("MASSIVE_API_KEY", nil))
      @api_key = api_key
    end

    # Fetch current-ish quote (uses previous close from Polygon/Massive)
    def fetch_quote(ticker)
      return { error: "Missing ticker" } if ticker.to_s.strip.empty?
      return { error: "Missing Massive API key" } if @api_key.to_s.strip.empty?

      Rails.cache.fetch(cache_key(ticker), expires_in: 1.minute) do
        details = fetch_ticker_details(ticker)
        return details if details[:error]

        price_info = fetch_previous_close(ticker)
        return price_info if price_info[:error]

        realtime = fetch_realtime_price(ticker)
        latest_price = realtime[:price] || price_info[:price]
        latest_ts = realtime[:at] || price_info[:previous_close_at]

        {
          name: details[:name],
          ticker: details[:ticker],
          sector: details[:sector],
          market_cap: details[:market_cap],
          price: latest_price,
          previous_close: price_info[:previous_close],
          previous_close_at: price_info[:previous_close_at],
          price_at: latest_ts,
          currency: details[:currency] || "USD",
          exchange: details[:exchange],
          fetched_at: Time.current
        }
      end
    rescue StandardError => e
      { error: "Lookup failed: #{e.message}" }
    end

    # Fetch historical OHLCV data as daily candles
    # Returns structure aligned with Yahoo client:
    # { ticker:, timestamps:, prices:, price_data: [ { timestamp, date, open, high, low, close, volume } ], meta: {} }
    def fetch_historical_data(ticker, range: "1y", interval: "1d")
      return { error: "Missing ticker" } if ticker.to_s.strip.empty?
      return { error: "Missing Massive API key" } if @api_key.to_s.strip.empty?

      days = range_to_days(range)
      from_date = (Date.today - days).strftime("%Y-%m-%d")
      to_date = Date.today.strftime("%Y-%m-%d")

      path = "/v2/aggs/ticker/#{CGI.escape(ticker)}/range/1/day/#{from_date}/#{to_date}"
      response = get_json(path, adjusted: true, sort: "asc", limit: 5000)
      return response if response[:error]

      results = response[:results] || []
      return { error: "No historical data for #{ticker}" } if results.empty?

      timestamps = []
      prices = []
      price_data = []

      results.each do |bar|
        ts = bar[:t] / 1000 # polygon returns ms
        timestamps << ts
        prices << bar[:c]
        price_data << {
          timestamp: ts,
          date: Time.at(ts).to_date,
          open: bar[:o],
          high: bar[:h],
          low: bar[:l],
          close: bar[:c],
          volume: bar[:v]
        }
      end

      {
        ticker: ticker.upcase,
        timestamps: timestamps,
        prices: prices,
        price_data: price_data,
        meta: { source: "massive" }
      }
    rescue StandardError => e
      { error: "Historical data lookup failed: #{e.message}" }
    end

    # Fetch price at a specific date by using aggregated bars
    def fetch_price_at_date(ticker, date)
      return { error: "Missing ticker" } if ticker.to_s.strip.empty?
      return { error: "Invalid date" } unless date.is_a?(Date) || date.is_a?(Time)

      target_date = date.to_date
      range = date_range_for(target_date)
      historical = fetch_historical_data(ticker, range: range, interval: "1d")
      return historical if historical[:error]

      timestamps = historical[:timestamps] || []
      prices = historical[:prices] || []
      return { error: "No data available" } if timestamps.empty?

      target_ts = target_date.to_time.to_i
      closest_index =
        if timestamps.first && timestamps.first > target_ts
          0
        else
          timestamps.find_index { |ts| ts >= target_ts } || timestamps.length - 1
        end

      return { error: "No price data for date" } if closest_index.nil? || prices[closest_index].nil?

      {
        price: prices[closest_index],
        date: Time.at(timestamps[closest_index]).to_date,
        timestamp: timestamps[closest_index]
      }
    end

    # Search tickers by company name or symbol fragment
    def search_tickers(query, limit: 3)
      term = query.to_s.strip
      return { error: "Missing search term" } if term.empty?
      return { error: "Missing Massive API key" } if @api_key.to_s.strip.empty?

      response = get_json("/v3/reference/tickers", search: term, active: true, limit: limit, sort: "market_cap", order: "desc")
      return response if response[:error]

      results = response[:results] || []
      return { error: "No tickers found for #{term}" } if results.empty?

      results.map do |r|
        {
          ticker: r[:ticker],
          name: r[:name],
          market_cap: r[:market_cap],
          currency: r[:currency_name],
          exchange: r[:primary_exchange],
          locale: r[:locale]
        }
      end
    rescue StandardError => e
      { error: "Search failed: #{e.message}" }
    end

    private

    def range_to_days(range)
      case range
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
    end

    def date_range_for(date)
      days_diff = (Date.today - date).to_i
      case days_diff
      when 0..5 then "5d"
      when 6..30 then "1mo"
      when 31..90 then "3mo"
      when 91..180 then "6mo"
      when 181..365 then "1y"
      else "2y"
      end
    end

    def fetch_ticker_details(ticker)
      path = "/v3/reference/tickers/#{CGI.escape(ticker)}"
      response = get_json(path)
      return response if response[:error]

      result = response[:results]
      return { error: "No data for #{ticker}" } unless result

      {
        name: result[:name],
        ticker: result[:ticker],
        sector: result[:sic_description],
        market_cap: result[:market_cap],
        currency: result[:currency_name],
        exchange: result[:primary_exchange]
      }
    end

    def fetch_previous_close(ticker)
      path = "/v2/aggs/ticker/#{CGI.escape(ticker)}/prev"
      response = get_json(path, adjusted: true)
      return response if response[:error]

      result = response[:results]&.first
      return { error: "No pricing data for #{ticker}" } unless result

      {
        price: result[:c],
        previous_close: result[:c],
        previous_close_at: result[:t] ? Time.at(result[:t] / 1000).to_datetime : nil
      }
    end

    def fetch_realtime_price(ticker)
      snap = fetch_snapshot(ticker)
      return snap if snap[:price]

      last = fetch_last_trade(ticker)
      return last if last[:price]

      {}
    end

    def fetch_snapshot(ticker)
      path = "/v2/snapshot/locale/us/markets/stocks/tickers/#{CGI.escape(ticker)}"
      response = get_json(path)
      return {} if response[:error]

      snap = response[:ticker] || {}
      last_trade = snap[:last_trade] || {}
      price = last_trade[:p]
      return {} unless price

      {
        price: price,
        at: last_trade[:t] ? Time.at(last_trade[:t] / 1000).to_datetime : nil
      }
    end

    def fetch_last_trade(ticker)
      path = "/v2/last/trade/#{CGI.escape(ticker)}"
      response = get_json(path)
      return {} if response[:error]

      trade = response[:results] || response[:result] || {}
      price = trade[:p] || trade[:price]
      return {} unless price

      {
        price: price,
        at: trade[:t] ? Time.at(trade[:t] / 1000).to_datetime : nil
      }
    end

    def get_json(path, params = {})
      uri = URI.join(base_url, path)
      uri.query = URI.encode_www_form(params) if params.any?

      response = perform_request(uri)
      return { error: "Request failed with #{response.code}" } unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body, symbolize_names: true)
    rescue JSON::ParserError
      { error: "Unexpected response format" }
    rescue StandardError => e
      { error: "Request error: #{e.message}" }
    end

    def perform_request(uri)
      Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: TIMEOUT_SECONDS, open_timeout: TIMEOUT_SECONDS) do |http|
        request = Net::HTTP::Get.new(uri)
        request["Authorization"] = "Bearer #{@api_key}"
        request["Accept"] = "application/json"

        http.request(request)
      end
    end

    def cache_key(ticker)
      "market_data:massive:quote:#{ticker.upcase}"
    end

    def base_url
      BASE_URL
    end
  end
end
