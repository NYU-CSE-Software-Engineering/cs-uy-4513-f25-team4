class CompaniesController < ApplicationController
  before_action :require_admin!
  before_action :set_company, only: [:show, :edit, :update]

  def index
    @companies = Company.order(:name)
  end

  def new
    @company = Company.new
  end

  def show
    client = market_data_client
    @market_data_source = client.is_a?(MarketData::MassiveClient) ? "Massive (Polygon)" : "Yahoo Finance"
    @quote = client.fetch_quote(@company.ticker)
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      redirect_to companies_path, notice: "Company was successfully created"
    else
      flash.now[:alert] = @company.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @company.update(company_params)
      redirect_to companies_path, notice: "Company was successfully updated"
    else
      flash.now[:alert] = @company.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :ticker, :sector, :market_cap, :tradable, :ipo_date)
  end

  def market_data_client
    if ENV["MASSIVE_API_KEY"].present?
      MarketData::MassiveClient.new
    else
      MarketData::YahooClient.new
    end
  end
end
