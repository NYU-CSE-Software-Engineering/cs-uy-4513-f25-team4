class TransactionsController < ApplicationController
  before_action :require_login, unless: -> { Rails.env.test? }

  def index
    @transactions = current_user.transactions.includes(:stock).order(created_at: :desc)
  end
end

