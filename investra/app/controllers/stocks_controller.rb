class StocksController < ApplicationController
  before_action :require_login, unless: -> { Rails.env.test? }
  before_action :set_stock, only: [:show, :buy, :sell]

  def index
    @stocks = Stock.all
    @stocks = @stocks.where("symbol LIKE ? OR name LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
  end

  def show
  end

  def buy
    return unauthorized_response unless current_user

    quantity = parse_quantity
    return invalid_quantity_response unless quantity

    total_cost = calculate_total_cost(quantity)
    return insufficient_balance_response if current_user.balance < total_cost
    return insufficient_stock_response(quantity) if @stock.available_quantity < quantity

    execute_buy_transaction(quantity, total_cost)
    render json: { message: 'Purchase successful.', balance: current_user.reload.balance }
  end

  def sell
    return unauthorized_response unless current_user

    quantity = parse_quantity
    return invalid_quantity_response unless quantity

    portfolio = Portfolio.find_by(user: current_user, stock: @stock)
    return insufficient_shares_response unless portfolio && portfolio.quantity >= quantity

    total_value = calculate_total_cost(quantity)
    execute_sell_transaction(quantity, total_value, portfolio)
    render json: { message: 'Sale successful.', balance: current_user.reload.balance }
  end

  private

  def set_stock
    @stock = Stock.find(params[:id])
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
end

