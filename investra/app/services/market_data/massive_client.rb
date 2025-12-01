require "net/http"
require "json"
require "cgi"

module MarketData
  class MassiveClient
    BASE_URL = ENV.fetch("MASSIVE_API_BASE", "https://api.polygon.io").freeze
    TIMEOUT_SECONDS = 5

    def initialize(api_key: ENV.fetch("MASSIVE_API_KEY", nil))
      @api_key = api_key
    end

    def fetch_quote(ticker)
      return { error: "Missing ticker" } if ticker.to_s.strip.empty?
      return { error: "Missing Massive API key" } if @api_key.to_s.strip.empty?

      Rails.cache.fetch(cache_key(ticker), expires_in: 1.minute) do
        details = fetch_ticker_details(ticker)
        return details if details[:error]

        price_info = fetch_previous_close(ticker)
        return price_info if price_info[:error]

        {
          name: details[:name],
          ticker: details[:ticker],
          sector: details[:sector],
          market_cap: details[:market_cap],
          price: price_info[:price],
          currency: details[:currency] || "USD",
          exchange: details[:exchange],
          fetched_at: Time.current
        }
      end
    rescue StandardError => e
      { error: "Lookup failed: #{e.message}" }
    end

    private

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

      { price: result[:c] }
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
