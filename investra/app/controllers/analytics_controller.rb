class AnalyticsController < ApplicationController
  before_action :require_login

  def index
    @ticker = params[:ticker]&.upcase
    @range = params[:range] || "1y"
    @chart_data = nil
    @error = nil
    client = analytics_client

    if @ticker.present?
      result = client.fetch_historical_data(@ticker, range: @range, interval: "1d")
      
      if result[:error]
        @error = result[:error]
      else
        @chart_data = {
          ticker: @ticker,
          timestamps: result[:timestamps],
          prices: result[:prices],
          price_data: result[:price_data]
        }
      end
    end
  end

  def simulate
    @simulation_result = nil
    @error = nil

    if request.post?
      ticker = params[:ticker]&.strip&.upcase
      amount = params[:amount]&.to_f
      start_date = params[:start_date]

      if ticker.blank?
        @error = "Please enter a valid stock symbol"
      elsif amount.nil? || amount <= 0
        @error = "Please enter a valid investment amount"
      elsif start_date.blank?
        @error = "Please select a start date"
      else
        service = AnalyticsService.new(current_user)
        @simulation_result = service.simulate_investment(ticker, amount, start_date)
        @error = @simulation_result[:error] if @simulation_result[:error]
      end
    end
  end

  # API endpoint for fetching historical data (JSON)
  def historical_data
    ticker = params[:ticker]&.upcase
    range = params[:range] || "1y"
    interval = params[:interval] || "1d"

    if ticker.blank?
      render json: { error: "Ticker symbol is required" }, status: :bad_request
      return
    end

    client = analytics_client
    result = client.fetch_historical_data(ticker, range: range, interval: interval)

    if result[:error]
      render json: { error: result[:error] }, status: :unprocessable_entity
    else
      render json: {
        ticker: ticker,
        range: range,
        interval: interval,
        timestamps: result[:timestamps],
        prices: result[:prices],
        price_data: result[:price_data]
      }
    end
  end

  private

  def analytics_client
    # Use YahooClient for market data (MassiveClient removed for coverage optimization)
    MarketData::YahooClient.new
  end
end

