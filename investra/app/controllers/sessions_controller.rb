class SessionsController < ApplicationController
  def new
    # Render login form
  end

  def create
    user = User.find_by(email: params[:email])
    
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      session[:user_email] = user.email

      case user.role
      when "Trader"
        redirect_to trader_dashboard_path, notice: "Login successful"
      when "Associate Trader"
        redirect_to associate_dashboard_path, notice: "Login successful"
      when "Portfolio Manager"
        redirect_to manager_dashboard_path, notice: "Login successful"
      when "System Administrator"
        redirect_to admin_dashboard_path, notice: "Login successful"
      else
        redirect_to root_path, notice: "Login successful"
      end
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

