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
      redirect_to dashboard_path_for(user), notice: "Login successful"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    # Fully clear session and rotate session id to invalidate cookie
    reset_session
    redirect_to login_path, notice: "Logged out successfully"
  end
  
  private
  
  def dashboard_path_for(user)
    case user.role
    when 'Trader' then trader_dashboard_path
    when 'Associate Trader' then associate_dashboard_path
    when 'Portfolio Manager' then manager_dashboard_path
    when 'System Administrator' then admin_dashboard_path
    else stocks_path # Fallback
    end
  end
end

