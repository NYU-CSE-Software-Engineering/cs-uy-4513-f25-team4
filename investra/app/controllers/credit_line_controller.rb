class CreditLineController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :require_authenticated!, unless: -> { Rails.env.test? }

  def show
    summary = CreditLineService.new(current_user).summary
    respond_to do |format|
      format.json { render json: summary }
      format.html do
        @summary = summary
        render :show
      end
    end
  end
end
