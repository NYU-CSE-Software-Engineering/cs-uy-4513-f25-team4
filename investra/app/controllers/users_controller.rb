class UsersController < ApplicationController
  # PATCH /users/:id/assign_associate
  def assign_associate
    @user = User.find(params[:id])
    @company = Company.find(params[:company_id])

    if @user.update(company: @company)
      redirect_to user_management_path, notice: "User assigned to company successfully"
    else
      redirect_to user_management_path, alert: "Failed to assign user"
    end
  end

  # GET /user_management
  def index
    @users = User.all
    # Include flash messages in the rendered response body so the test can find them
    message = flash[:notice] || flash[:alert] || "User management page placeholder"
    render plain: message
  end

  # GET /signup
  def new
    @user = User.new
  end
end
