class MarketDataService
  # Placeholder market data lookup. Replace with real client (e.g., MarketData::MassiveClient).
  def self.get_price(symbol)
    Rails.cache.fetch("market_price:#{symbol}", expires_in: 1.minute) do
      nil # Return nil so we fall back to stored price until a real feed is wired up.
    end
  end
end
