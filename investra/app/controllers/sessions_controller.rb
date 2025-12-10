class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    # Render login form
  end

  def create
    user = User.find_by(email: params[:email])
    
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      session[:user_email] = user.email
      
      # Redirect based on user role
      redirect_path = case user.role&.strip&.downcase
                      when "trader", "Trader"
                        trader_dashboard_path
                      when "associate_trader", "Associate Trader"
                        associate_dashboard_path
                      when "portfolio_manager", "Portfolio Manager"
                        manager_dashboard_path
                      when "system_administrator", "System Administrator"
                        admin_dashboard_path
                      else
                        stocks_path
                      end
      
      redirect_to redirect_path, notice: "Login successful"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    session[:user_email] = nil
    redirect_to login_path, notice: "Logged out successfully"
  end
end
