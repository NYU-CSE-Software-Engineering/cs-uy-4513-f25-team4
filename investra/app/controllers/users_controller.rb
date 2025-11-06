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
      redirect_to root_path, notice: "User created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end
<<<<<<< HEAD

=======
  
  def show
    @user = User.find(params[:id])
  end
  
  def assign_admin
    @user = User.find(params[:id])
    @user.update!(role: "admin")
    redirect_to @user, notice: "User assigned as admin successfully."
  end
  
>>>>>>> 33dd723 (Make PATCH /users/:id/assign_admin request spec pass)
  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation, :role)
  end
end