class DashboardController < ApplicationController
  before_action :require_login

  def trader
    @user = User.find(session[:user_id])
  end

  def associate
    @user = User.find(session[:user_id])
  end

  def manager
    @user = User.find(session[:user_id])
  end

  def admin
    @user = User.find(session[:user_id])
  end

  private

  def require_login
    unless session[:user_id]
      redirect_to '/login'
    end
  end
end
