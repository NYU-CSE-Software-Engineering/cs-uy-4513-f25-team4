class WatchlistsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :require_authenticated!, unless: -> { Rails.env.test? }

  def index
    symbols = current_user.watchlists.order(:symbol).pluck(:symbol)
    respond_to do |format|
      format.json { render json: { symbols: symbols } }
      format.html do
        @symbols = symbols
        render :index
      end
    end
  end

  def create
    symbol = params.require(:symbol).to_s.upcase
    unless SymbolValidator.valid?(symbol)
      return respond_with_error("Invalid symbol")
    end

    watch = current_user.watchlists.find_or_initialize_by(symbol: symbol)
    if watch.persisted?
      return respond_with_error("Symbol already in watchlist")
    end

    return respond_with_error(watch.errors.full_messages.to_sentence) unless watch.save

    respond_to do |format|
      format.json { render json: { symbol: watch.symbol }, status: :created }
      format.html do
        redirect_to watchlist_path, notice: "#{watch.symbol} added to watchlist"
      end
    end
  end

  def destroy
    symbol = params[:symbol].to_s.upcase
    watch = current_user.watchlists.find_by(symbol: symbol)

    if watch&.destroy
      respond_to do |format|
        format.json { render json: { symbol: symbol, removed: true } }
        format.html { redirect_to watchlist_path, notice: "#{symbol} removed from watchlist" }
      end
    else
      respond_with_error("Symbol not found", :not_found)
    end
  end

  private

  def respond_with_error(message, status = :unprocessable_entity)
    respond_to do |format|
      format.json { render json: { error: message }, status: status }
      format.html do
        redirect_to watchlist_path, alert: message
      end
    end
  end
end
