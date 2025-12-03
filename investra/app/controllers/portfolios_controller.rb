class PortfoliosController < ApplicationController
  before_action :require_login, unless: -> { Rails.env.test? }

  def show
    @portfolios = current_user.portfolios.includes(:stock)
  end
end

