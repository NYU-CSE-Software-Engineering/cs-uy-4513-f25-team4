class PortfolioSummaryService
  def initialize(user, market_data: MarketDataService)
    @user = user
    @market_data = market_data
  end

  def call
    holdings = build_holdings
    holdings_total = holdings.sum { |h| h[:market_value] }
    cash_balance = @user.balance || 0

    {
      user_id: @user.id,
      total_value: holdings_total + cash_balance,
      cash_balance: cash_balance,
      holdings: holdings
    }
  end

  private

  def build_holdings
    @user.portfolios.includes(:stock).map do |position|
      stock = position.stock
      market_price = fetch_market_price(stock)
      cost_basis = cost_basis_per_share(position)

      {
        symbol: stock.symbol,
        quantity: position.quantity,
        cost_basis: cost_basis,
        market_price: market_price,
        market_value: (market_price * position.quantity).to_f,
        gain_loss: ((market_price - cost_basis) * position.quantity).to_f
      }
    end
  end

  def fetch_market_price(stock)
    @market_data.get_price(stock.symbol) || stock.price.to_f
  rescue StandardError
    stock.price.to_f
  end

  # Simple average cost basis based on historical transactions for this user/stock.
  # Falls back to the current stored stock price if no history exists.
  def cost_basis_per_share(position)
    transactions = @user.transactions.where(stock_id: position.stock_id)
    return position.stock.price.to_f if transactions.blank?

    buys_cost = transactions.where(transaction_type: "buy").sum("quantity * price")
    sells_cost = transactions.where(transaction_type: "sell").sum("quantity * price")
    net_cost = buys_cost - sells_cost

    quantity = position.quantity.nonzero? || 1
    (net_cost.to_f / quantity).round(2)
  end
end
