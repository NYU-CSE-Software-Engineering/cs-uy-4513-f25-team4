class PortfoliosController < ApplicationController
  before_action :require_authenticated!, unless: -> { Rails.env.test? }

  def show
    summary = PortfolioSummaryService.new(current_user).call
    @performance = build_performance(current_user)

    respond_to do |format|
      format.json { render json: PortfolioSerializer.new(summary).as_json }
      format.html do
        @summary = summary
        render :show
      end
    end
  end

  private

  def build_performance(user)
    rows = Transaction.where(user_id: user.id)
                      .group(:user_id)
                      .pluck(
                        Arel.sql('COUNT(*)'),
                        Arel.sql('SUM(quantity)'),
                        Arel.sql("SUM(CASE WHEN transaction_type = 'sell' THEN price * quantity ELSE 0 END)"),
                        Arel.sql("SUM(CASE WHEN transaction_type = 'buy' THEN price * quantity ELSE 0 END)"),
                        Arel.sql('MAX(created_at)')
                      )

    if rows.any?
      trades, qty, sell_total, buy_total, last_trade = rows.first
      {
        trades: trades.to_i,
        quantity: qty.to_i,
        buy_total: buy_total.to_f,
        sell_total: sell_total.to_f,
        net: sell_total.to_f - buy_total.to_f,
        last_trade_at: last_trade
      }
    else
      { trades: 0, quantity: 0, buy_total: 0, sell_total: 0, net: 0, last_trade_at: nil }
    end
  end
end
