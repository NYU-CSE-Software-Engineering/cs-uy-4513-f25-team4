class DashboardController < ApplicationController
  before_action :require_login

  def trader
    @user = User.find(session[:user_id])
    rows = Transaction.where(user_id: @user.id)
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
      @performance = {
        trades: trades.to_i,
        quantity: qty.to_i,
        buy_total: buy_total.to_f,
        sell_total: sell_total.to_f,
        net: sell_total.to_f - buy_total.to_f,
        last_trade_at: last_trade
      }
    else
      @performance = { trades: 0, quantity: 0, buy_total: 0, sell_total: 0, net: 0, last_trade_at: nil }
    end
  end

  def deposit
    @user = User.find(session[:user_id])
    amount = params[:amount].to_f
    if amount <= 0
      redirect_to trader_dashboard_path, alert: "Amount must be greater than 0" and return
    end

    @user.update!(balance: @user.balance.to_f + amount)
    redirect_to trader_dashboard_path, notice: "Balance topped up by $#{format('%.2f', amount)}"
  rescue StandardError => e
    redirect_to trader_dashboard_path, alert: "Deposit failed: #{e.message}"
  end

  def associate
    @user = User.find(session[:user_id])
  end

  def manager
    @user = User.find(session[:user_id])
  end

  def admin
    @user = User.find(session[:user_id])
  end

  private

  def require_login
    unless session[:user_id]
      redirect_to '/login'
    end
  end
end
