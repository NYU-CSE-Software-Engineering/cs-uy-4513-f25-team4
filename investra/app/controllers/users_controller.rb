class UsersController < ApplicationController
  # GET /manage_team
  def manage_team
    if session[:user_email]
      @current_user = User.find_by(email: session[:user_email])
    end
    @current_user ||= User.where(role: ['Portfolio Manager', 'portfolio_manager']).first

    unless @current_user
      @associates = User.none
      @available_traders = User.none
      @selected_trader = nil
      @confirm_remove_user = nil
      @search_term = ""
      @show_traders = false
      return
    end

    @associates = User.where(manager: @current_user)

    base_scope = User.where(role: ['Trader', 'trader'])
    base_scope =
      if @current_user.company
        base_scope.where(company: [nil, @current_user.company])
      else
        base_scope.where(company: nil)
      end

    @search_term = params[:search].to_s.strip
    if @search_term.present?
      term = "%#{@search_term.downcase}%"
      base_scope = base_scope.where(
        "LOWER(first_name) LIKE :term OR LOWER(last_name) LIKE :term OR LOWER(email) LIKE :term",
        term: term
      )
    end

    @available_traders = base_scope.order(:email)

    @selected_trader = nil
    if params[:selected_user_id].present?
      @selected_trader = @available_traders.find_by(id: params[:selected_user_id])
    end

    @confirm_remove_user = nil
    if params[:confirm_remove_id].present?
      @confirm_remove_user = @associates.find_by(id: params[:confirm_remove_id])
    end

    @show_traders = params[:show_traders] == 'true' || @selected_trader.present? || @search_term.present?
  end

  # POST /users/:id/assign_as_associate
  def assign_as_associate
    @user = User.find(params[:id])
    if session[:user_email]
      @current_user = User.find_by(email: session[:user_email])
    end
    @current_user ||= User.where(role: ['Portfolio Manager', 'portfolio_manager']).first
    
    if @current_user && @user.assign_as_associate!(@current_user)
      redirect_to manage_team_path, notice: "Associate added successfully"
    else
      redirect_to manage_team_path, alert: "Failed to assign associate"
    end
  end

  # DELETE /users/:id/remove_associate
  def remove_associate
    @user = User.find(params[:id])
    
    if @user.remove_associate!
      redirect_to manage_team_path, notice: "Associate removed successfully"
    else
      redirect_to manage_team_path, alert: "Failed to remove associate"
    end
  end

  # PATCH /users/:id/assign_associate (legacy)
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
    user_params = params.require(:user).permit(:role, :company, :manager)
    
    updates = { role: user_params[:role] }
    
    # Handle company - form always sends a value (either company name or empty string for "None")
    company_name = user_params[:company].to_s.strip
    company_provided = false
    if company_name.present? && company_name != 'None'
      company = Company.find_by(name: company_name)
      if company
        updates[:company] = company
        company_provided = true
      end
      # If company not found, don't set it - will use manager's company for Associate Trader if applicable
    else
      # Empty string or "None" means no company explicitly selected
      # For Associate Trader, we'll use manager's company if available
    end
    
    # Handle manager
    if ['Portfolio Manager', 'portfolio_manager'].include?(user_params[:role])
      # Portfolio Managers don't have managers
      updates[:manager] = nil
    else
      manager_email = user_params[:manager].to_s.strip
      if manager_email.present? && manager_email != 'None'
        manager = User.find_by(email: manager_email)
        updates[:manager] = manager if manager
      else
        # Empty string or "None" means no manager
        updates[:manager] = nil
      end
    end
    
    # If assigning as Associate Trader and company not provided but manager is set, use manager's company
    if ['Associate Trader', 'associate_trader'].include?(user_params[:role]) && updates[:manager] && !company_provided
      updates[:company] = updates[:manager].company
    elsif !company_provided && !['Associate Trader', 'associate_trader'].include?(user_params[:role])
      # For other roles, if no company provided, set to nil
      updates[:company] = nil
    end

    if @user.update(updates)
      redirect_to user_management_path, notice: "Role updated successfully"
    else
      redirect_to user_management_path, alert: @user.errors.full_messages.to_sentence
    end
  end

  # GET /user_management
  def index
    @users = User.all
    @companies = Company.all
    @managers = User.where(role: ['Portfolio Manager', 'portfolio_manager'])
  end
  
  # GET /users/:id/edit
  def edit
    @user = User.find(params[:id])
    @companies = Company.all
    @managers = User.where(role: ['Portfolio Manager', 'portfolio_manager'])
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


  def profile
    unless session[:user_id]
      redirect_to login_path, alert: "Please log in" and return
    end
    
    @user = User.find(session[:user_id])
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
    redirect_to login_path, alert: "Please log in"
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

