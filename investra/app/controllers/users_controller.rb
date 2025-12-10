class UsersController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  before_action :require_login, only: [:show]

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

    # Show available users who can be assigned: Traders or unassigned Associate Traders
    base_scope = User.where(role: ['Trader', 'trader', 'Associate Trader', 'associate_trader'], manager_id: nil)
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

    @pending_requests = ManagerRequest.where(manager: @current_user, status: "pending")

    # Basic performance metrics for associates (from transactions)
    @associate_performance = {}
    if @associates.any?
      rows = Transaction.where(user_id: @associates.pluck(:id))
                        .group(:user_id)
                        .pluck(
                          :user_id,
                          Arel.sql("COUNT(*) AS trades"),
                          Arel.sql("SUM(quantity) AS total_qty"),
                          Arel.sql("SUM(CASE WHEN transaction_type = 'sell' THEN price * quantity ELSE 0 END) AS sell_total"),
                          Arel.sql("SUM(CASE WHEN transaction_type = 'buy' THEN price * quantity ELSE 0 END) AS buy_total"),
                          Arel.sql("MAX(created_at) AS last_trade_at")
                        )
      rows.each do |user_id, trades, qty, sell_total, buy_total, last_trade_at|
        sell_total = sell_total.to_f
        buy_total = buy_total.to_f
        @associate_performance[user_id] = {
          trades: trades.to_i,
          quantity: qty.to_i,
          buy_total: buy_total,
          sell_total: sell_total,
          net: sell_total - buy_total,
          last_trade_at: last_trade_at
        }
      end
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
    user_params = params.require(:user).permit(:role, :company, :manager)
    
    # Update roles (many-to-many)
    role_name = user_params[:role]
    if role_name.present?
      @user.roles.clear
      role = Role.find_or_create_by(name: role_name)
      @user.roles << role
    end
    
    updates = {}
    
    company_name = user_params[:company].to_s.strip
    company_provided = false
    if company_name.present? && company_name != 'None'
      company = Company.find_by(name: company_name)
      if company
        updates[:company] = company
        company_provided = true
      end
    end
    
    if ['Portfolio Manager', 'portfolio_manager'].include?(role_name)
      updates[:manager] = nil
    else
      manager_email = user_params[:manager].to_s.strip
      if manager_email.present? && manager_email != 'None'
        manager = User.find_by(email: manager_email)
        updates[:manager] = manager if manager
      else
        updates[:manager] = nil
      end
    end
    
    if ['Associate Trader', 'associate_trader'].include?(role_name) && updates[:manager] && !company_provided
      updates[:company] = updates[:manager].company
    elsif !company_provided && !['Associate Trader', 'associate_trader'].include?(role_name)
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
    @companies = Company.order(:name)
  end

  # POST /users
  def create
    @user = User.new(user_params)
    
    # Assign selected role
    role_name = params[:role_name] || 'Trader'
    role = Role.find_or_create_by(name: role_name)
    company_name = params[:company_name].to_s.strip
    
    # Handle company for Portfolio Manager and Associate Trader
    if role_name == 'Associate Trader'
      domain = @user.email.split('@').last
      company = Company.find_by(name: company_name.presence) || Company.find_by(domain: domain)

      unless company
        @user.errors.add(:company, "must be an existing company for Associate Trader")
        @companies = Company.order(:name)
        return render :new, status: :unprocessable_entity, layout: true
      end

      @user.company = company
    elsif role_name == 'Portfolio Manager'
      domain = @user.email.split('@').last
      company = Company.find_by(domain: domain)
      
      if company.nil? && params[:company_name].present?
        company = Company.create!(
          name: params[:company_name],
          domain: domain
        )
      end
      
      @user.company = company if company
    end

    @user.role = role_name
    if @user.save
      @user.roles << role unless @user.roles.exists?(id: role.id)
      if role_name == 'Associate Trader' && @user.company_id.present?
        manager = User.find_by(role: ['Portfolio Manager', 'portfolio_manager'], company_id: @user.company_id)
        ManagerRequest.create!(user: @user, manager: manager) if manager
      end
      session[:user_id] = @user.id
      
      dashboard_path = case role_name
      when 'Portfolio Manager'
        '/dashboard/manager'
      when 'Associate Trader'
        '/dashboard/associate'
      when 'System Administrator'
        '/dashboard/admin'
      else
        '/dashboard/trader'
      end
      
      redirect_to dashboard_path, notice: 'Registration successful'
    else
      render :new, status: :unprocessable_entity, layout: true
    end
  end

  # GET /users/:id
  def show
    if session[:user_id]
      @user = User.find(session[:user_id])
    else
      redirect_to '/login', alert: 'Please log in'
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation)
  end

  def require_login
    unless session[:user_id]
      redirect_to '/login', alert: 'Please log in'
    end
  end
end
