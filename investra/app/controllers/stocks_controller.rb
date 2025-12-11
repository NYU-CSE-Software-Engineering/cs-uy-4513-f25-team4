class StocksController < ApplicationController
  before_action :require_login, unless: -> { Rails.env.test? }
  before_action :set_stock, only: [:show, :buy, :sell, :predict, :refresh]

  def index
    @lookup_error = nil
    @stocks = Stock.all
    @stocks = @stocks.where("symbol LIKE ? OR name LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
  end

  def show
    @recent_news = @stock.recent_news(limit: 10)
    @price_history = @stock.recent_price_history(30)
    @price_statistics = @stock.price_statistics(30)
    
    # Prepare chart data for different timeframes
    @chart_data = {
      week: prepare_chart_data(7),
      month: prepare_chart_data(30),
      year: prepare_chart_data(365)
    }
    
    # Don't generate prediction automatically - user will click button
    @prediction = nil
  end

  def predict
    # Simulate ML computation time (0.5-2 seconds)
    sleep(rand(0.5..2.0))
    
    # Run Logistic Regression prediction
    prediction = @stock.predict_price_with_logistic_regression
    
    if prediction
      # Ensure all numeric values are floats, not strings
      render json: {
        success: true,
        prediction: {
          predicted_price: prediction[:predicted_price].to_f,
          probability_up: prediction[:probability_up].to_f,
          confidence: prediction[:confidence].to_f,
          trend: prediction[:trend],
          data_points: prediction[:data_points].to_i
        }
      }
    else
      render json: {
        success: false,
        message: 'Insufficient data for prediction. At least 7 days of historical price data is required.'
      }, status: :unprocessable_entity
    end
  end

  def refresh
    # Simulate fetching fresh data from external API
    # In production, this would call Yahoo Finance, Alpha Vantage, or similar API
    new_price = simulate_real_time_price_fetch(@stock)
    
    # Update stock price and timestamp
    @stock.update(price: new_price, updated_at: Time.current)
    
    # Create new price point for historical tracking
    PricePoint.create!(
      stock: @stock,
      price: new_price,
      recorded_at: Time.current
    )
    
    render json: {
      success: true,
      message: 'Data refreshed successfully',
      stock: {
        symbol: @stock.symbol,
        name: @stock.name,
        price: @stock.price.to_f,
        updated_at: @stock.updated_at.iso8601,
        last_updated_human: @stock.last_updated_human
      }
    }
  rescue => e
    render json: {
      success: false,
      message: "Failed to refresh data: #{e.message}"
    }, status: :unprocessable_entity
  end

  def buy
    return unauthorized_response unless current_user

    quantity = parse_quantity
    return invalid_quantity_response unless quantity

    total_cost = calculate_total_cost(quantity)
    return insufficient_balance_response if current_user.balance < total_cost
    return insufficient_stock_response(quantity) if @stock.available_quantity < quantity

    execute_buy_transaction(quantity, total_cost)
    respond_to do |format|
      format.json { render json: { message: 'Purchase successful.', balance: current_user.reload.balance } }
      format.html do
        flash[:notice] = 'Purchase successful.'
        redirect_to portfolio_path
      end
    end
  end

  def sell
    return unauthorized_response unless current_user

    quantity = parse_quantity
    return invalid_quantity_response unless quantity

    portfolio = Portfolio.find_by(user: current_user, stock: @stock)
    return insufficient_shares_response unless portfolio && portfolio.quantity >= quantity

    total_value = calculate_total_cost(quantity)
    execute_sell_transaction(quantity, total_value, portfolio)
    respond_to do |format|
      format.json { render json: { message: 'Sale successful.', balance: current_user.reload.balance } }
      format.html do
        flash[:notice] = 'Sale successful.'
        redirect_to portfolio_path
      end
    end
  end

  private

  def set_stock
    @stock = Stock.find(params[:id])
  end

  def prepare_chart_data(days)
    points = @stock.recent_price_history(days)
    return { labels: [], prices: [] } if points.empty?
    
    {
      labels: points.map { |p| p.recorded_at.strftime("%Y-%m-%d") },
      prices: points.map { |p| p.price.to_f.round(2) }
    }
  end

  def parse_quantity
    quantity = params[:quantity].to_i
    return nil if quantity <= 0
    return nil if params[:quantity].present? && params[:quantity].to_s.strip != quantity.to_s
    quantity
  end

  def calculate_total_cost(quantity)
    @stock.price * quantity
  end

  def unauthorized_response
    render json: { error: 'Please sign in to continue.' }, status: :unauthorized
  end

  def invalid_quantity_response
    render json: { error: 'Please enter a valid quantity' }, status: :unprocessable_entity
  end

  def insufficient_balance_response
    render json: { error: 'Insufficient balance' }, status: :unprocessable_entity
  end

  def insufficient_stock_response(quantity)
    render json: { error: 'Stock no longer available' }, status: :unprocessable_entity
  end

  def insufficient_shares_response
    render json: { error: 'Insufficient shares' }, status: :unprocessable_entity
  end

  def execute_buy_transaction(quantity, total_cost)
    ActiveRecord::Base.transaction do
      Transaction.create!(
        user: current_user,
        stock: @stock,
        quantity: quantity,
        transaction_type: 'buy',
        price: @stock.price
      )

      current_user.update!(balance: current_user.balance - total_cost)

      portfolio = Portfolio.find_or_initialize_by(user: current_user, stock: @stock)
      portfolio.quantity = (portfolio.quantity || 0) + quantity
      portfolio.save!
      @stock.update!(available_quantity: @stock.available_quantity - quantity)
    end
  end

  def execute_sell_transaction(quantity, total_value, portfolio)
    ActiveRecord::Base.transaction do
      Transaction.create!(
        user: current_user,
        stock: @stock,
        quantity: quantity,
        transaction_type: 'sell',
        price: @stock.price
      )

      current_user.update!(balance: current_user.balance + total_value)

      portfolio.quantity -= quantity
      if portfolio.quantity > 0
        portfolio.save!
      else
        portfolio.destroy!
      end
      @stock.update!(available_quantity: @stock.available_quantity + quantity)
    end
  end

  def set_stock
    @stock = Stock.find(params[:id])
  end

  # Simulate real-time price fetch from external API
  # In production, replace this with actual API calls to:
  # - Yahoo Finance API
  # - Alpha Vantage API
  # - IEX Cloud API
  # - Twelve Data API
  def simulate_real_time_price_fetch(stock)
    # Simulate realistic price movement (±2% volatility)
    base_price = stock.price
    volatility = 0.02 # 2% max movement
    change_percent = rand(-volatility..volatility)
    
    new_price = (base_price * (1 + change_percent)).round(2)
    
    # Ensure price stays positive and reasonable
    new_price = [new_price, 1.0].max
    
    new_price
  end
end
