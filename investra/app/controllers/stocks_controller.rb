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
    # Accept quantity as integer or string, convert to integer
    quantity = params[:quantity].to_i

    # Validate: quantity must be positive integer
    # Check if original param was a valid positive number
    if quantity <= 0 || (params[:quantity].present? && params[:quantity].to_s.strip != quantity.to_s)
      render json: { error: 'Please enter a valid quantity' }, status: :unprocessable_entity
      return
    end

    total_cost = @stock.price * quantity

    if current_user.balance < total_cost
      render json: { error: 'Insufficient balance' }, status: :unprocessable_entity
      return
    end

    if @stock.available_quantity < quantity
      render json: { error: 'Stock no longer available' }, status: :unprocessable_entity
      return
    end

    ActiveRecord::Base.transaction do
      # Create transaction record
      Transaction.create!(
        user: current_user,
        stock: @stock,
        quantity: quantity,
        transaction_type: 'buy',
        price: @stock.price
      )

      # Update user balance
      current_user.update!(balance: current_user.balance - total_cost)

      # Update or create portfolio entry
      portfolio = Portfolio.find_or_initialize_by(user: current_user, stock: @stock)
      portfolio.quantity = (portfolio.quantity || 0) + quantity
      portfolio.save!

      # Update stock available quantity
      @stock.update!(available_quantity: @stock.available_quantity - quantity)
    end

    render json: { message: 'Purchase successful.', balance: current_user.reload.balance }
  end

  def sell
    quantity = params[:quantity].to_i

    if quantity <= 0 || params[:quantity].to_s != quantity.to_s
      render json: { error: 'Please enter a valid quantity' }, status: :unprocessable_entity
      return
    end

    portfolio = Portfolio.find_by(user: current_user, stock: @stock)

    unless portfolio && portfolio.quantity >= quantity
      render json: { error: 'Insufficient shares' }, status: :unprocessable_entity
      return
    end

    total_value = @stock.price * quantity

    ActiveRecord::Base.transaction do
      # Create transaction record
      Transaction.create!(
        user: current_user,
        stock: @stock,
        quantity: quantity,
        transaction_type: 'sell',
        price: @stock.price
      )

      # Update user balance
      current_user.update!(balance: current_user.balance + total_value)

      # Update portfolio
      portfolio.quantity -= quantity
      if portfolio.quantity > 0
        portfolio.save!
      else
        portfolio.destroy!
      end

      # Update stock available quantity
      @stock.update!(available_quantity: @stock.available_quantity + quantity)
    end

    render json: { message: 'Sale successful.', balance: current_user.reload.balance }
  end

  private

  def set_stock
    @stock = Stock.find(params[:id])
  end
end

