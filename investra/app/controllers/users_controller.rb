class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: "Account created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def assign_admin
    @user = User.find(params[:id])
    @user.update!(role: "admin")
    redirect_to @user, notice: "User assigned as admin successfully."
  end
  
  def update_role
    @user = User.find(params[:id])
    if @user.update(role: params[:user][:role])
      redirect_to user_management_path, notice: "User role updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  private

  def management
    @users = User.all
    render :management
  end
  
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :role, :company_id)
  end
end
