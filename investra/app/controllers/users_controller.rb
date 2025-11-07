class UsersController < ApplicationController
  # PATCH /users/:id/assign_associate
  def assign_associate
    @user = User.find(params[:id])
    @company = Company.find_by(id: params[:company_id])

    if @company && @user.update(company: @company)
      redirect_to user_management_path, notice: "User assigned to company successfully"
    else
      redirect_to user_management_path, alert: "Failed to assign user"
    end
  end

  # PATCH /users/:id/assign_admin
  def assign_admin
    @user = User.find(params[:id])
    @user.update!(role: "admin")
    redirect_to @user, notice: "User assigned as admin successfully."
  end

  # PATCH /users/:id/update_role
  def update_role
    @user = User.find(params[:id])
    new_role = params.require(:user).permit(:role)[:role]

    if @user.update(role: new_role)
      redirect_to user_management_path, notice: "User role updated successfully."
    else
      redirect_to user_management_path, alert: @user.errors.full_messages.to_sentence
    end
  end

  # GET /user_management
  def index
    @users = User.all
    message = flash[:notice] || flash[:alert] || "User management page placeholder"
    render plain: message
  end

  # GET /signup
  def new
    @user = User.new
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: "User created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /users/:id
  def show
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation, :role)
  end
end

