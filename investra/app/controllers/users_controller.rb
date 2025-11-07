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
  
  def edit
    @user = User.find(params[:id])
    @companies = Company.all
    @managers = User.where(role: 'Portfolio Manager')
  end
  
  def update
    @user = User.find(params[:id])
    new_role = params[:user][:role]
    update_params = { role: new_role }
    
    # Handle company selection by name
    if params[:user][:company].present?
      company = Company.find_by(name: params[:user][:company])
      update_params[:company_id] = company.id if company
    end
    
    # Handle manager selection by email
    # Only Associate Traders can have managers
    if new_role == 'Associate Trader'
      if params[:user][:manager].present?
        manager = User.find_by(email: params[:user][:manager])
        update_params[:manager_id] = manager.id if manager
      end
    else
      # Clear manager if role is not Associate Trader
      update_params[:manager_id] = nil
    end
    
    if @user.update(update_params)
      redirect_to user_management_path, notice: "Role updated successfully"
    else
      @companies = Company.all
      @managers = User.where(role: 'Portfolio Manager')
      render :edit, status: :unprocessable_entity
    end
  end
  
  def assign_admin
    @user = User.find(params[:id])
    @user.update!(role: "admin")
    redirect_to @user, notice: "User assigned as admin successfully."
  end
  
  def update_role
    @user = User.find(params[:id])
    update_params = { role: params[:user][:role] }
    
    # Handle company selection
    if params[:user][:company].present?
      company = Company.find_by(name: params[:user][:company])
      update_params[:company_id] = company.id if company
    end
    
    # Handle manager selection
    if params[:user][:manager].present?
      manager = User.find_by(email: params[:user][:manager])
      update_params[:manager_id] = manager.id if manager
    end
    
    if @user.update(update_params)
      redirect_to user_management_path, notice: "Role updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def management
    @users = User.all
    render :management
  end
  
  private
  
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :role, :company_id, :password, :password_confirmation)
  end
  
  def user_update_params
    params.require(:user).permit(:role, :company_id, :manager_id)
  end
end
