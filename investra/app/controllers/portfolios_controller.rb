class PortfoliosController < ApplicationController
  before_action :require_authenticated!, unless: -> { Rails.env.test? }

  def show
    summary = PortfolioSummaryService.new(current_user).call

    respond_to do |format|
      format.json { render json: PortfolioSerializer.new(summary).as_json }
      format.html do
        @summary = summary
        render :show
      end
    end
  end
end
