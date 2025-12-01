require "net/http"
require "json"

module MarketData
  class YahooClient
    BASE_URL = "https://query1.finance.yahoo.com/v7/finance/quote".freeze
    TIMEOUT_SECONDS = 5

    def fetch_quote(ticker)
      return { error: "Missing ticker" } if ticker.to_s.strip.empty?

      Rails.cache.fetch(cache_key(ticker), expires_in: 5.minutes) do
        uri = URI(BASE_URL)
        uri.query = URI.encode_www_form(symbols: ticker)

        response = perform_request(uri)
        return { error: "Request failed with #{response.code}" } unless response.is_a?(Net::HTTPSuccess)

        parse_body(response.body, ticker)
      end
    rescue StandardError => e
      { error: "Lookup failed: #{e.message}" }
    end

    private

    def perform_request(uri)
      Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: TIMEOUT_SECONDS, open_timeout: TIMEOUT_SECONDS) do |http|
        http.get(uri.request_uri)
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

    def cache_key(ticker)
      "market_data:quote:#{ticker.upcase}"
    end
  end
end
