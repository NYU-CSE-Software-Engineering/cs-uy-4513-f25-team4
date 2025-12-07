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
      redirect_to stocks_path, notice: "Signed in successfully"
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

