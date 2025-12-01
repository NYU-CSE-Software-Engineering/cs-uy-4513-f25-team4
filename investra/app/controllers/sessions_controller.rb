class SessionsController < ApplicationController
  def new
    # Render login form
  end

  def create
    user = User.find_by(email: params[:email])
    
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      role = user.roles.first&.name
      dashboard_path = case role
      when 'Portfolio Manager'
        '/dashboard/manager'
      when 'Associate Trader'
        '/dashboard/associate'
      when 'System Administrator'
        '/dashboard/admin'
      else
        '/dashboard/trader'
      end
      redirect_to dashboard_path, notice: "Login successful"
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

