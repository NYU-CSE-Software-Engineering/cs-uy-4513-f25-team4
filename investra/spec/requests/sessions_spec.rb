require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let(:trader_role) { Role.find_or_create_by(name: 'Trader') }
  let!(:user) do
    user = User.create!(
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      first_name: 'Test',
      last_name: 'User'
    )
    user.roles << trader_role unless user.roles.exists?(id: trader_role.id)
    user
  end

  describe "GET /login" do
    it "returns http success" do
      get login_path
      expect(response).to have_http_status(:success)
    end

    it "renders the login form" do
      get login_path
      expect(response.body).to include('Log In')
      expect(response.body).to include('Email')
      expect(response.body).to include('Password')
    end
  end

  describe "POST /login" do
    context "with valid credentials" do
      let(:valid_credentials) do
        {
          email: 'test@example.com',
          password: 'password123'
        }
      end

      it "creates a session" do
        post login_path, params: valid_credentials
        expect(session[:user_id]).to eq(user.id)
      end

      it "redirects to appropriate dashboard" do
        post login_path, params: valid_credentials
        expect(response).to redirect_to(trader_dashboard_path)
      end

      it "shows success message" do
        post login_path, params: valid_credentials
        follow_redirect!
        expect(response.body).to include('Login successful')
      end
    end

    context "with invalid email" do
      let(:invalid_email) do
        {
          email: 'wrong@example.com',
          password: 'password123'
        }
      end

      it "does not create a session" do
        post login_path, params: invalid_email
        expect(session[:user_id]).to be_nil
      end

      it "re-renders login form" do
        post login_path, params: invalid_email
        expect(response.body).to include('Log In')
      end

      it "shows error message" do
        post login_path, params: invalid_email
        expect(response.body).to include('Invalid email or password')
      end
    end

    context "with invalid password" do
      let(:invalid_password) do
        {
          email: 'test@example.com',
          password: 'wrongpassword'
        }
      end

      it "does not create a session" do
        post login_path, params: invalid_password
        expect(session[:user_id]).to be_nil
      end

      it "shows error message" do
        post login_path, params: invalid_password
        expect(response.body).to include('Invalid email or password')
      end
    end

    context "with missing credentials" do
      it "handles missing email" do
        post login_path, params: { password: 'password123' }
        expect(session[:user_id]).to be_nil
      end

      it "handles missing password" do
        post login_path, params: { email: 'test@example.com' }
        expect(session[:user_id]).to be_nil
      end
    end
  end

  describe "DELETE /logout" do
    before do
      # Log the user in first
      post login_path, params: { email: 'test@example.com', password: 'password123' }
    end

    it "destroys the session" do
      delete logout_path
      expect(session[:user_id]).to be_nil
    end

    it "redirects to login page" do
      delete logout_path
      expect(response).to redirect_to(login_path)
    end

    it "shows logout message" do
      delete logout_path
      follow_redirect!
      expect(response.body).to include('Logged out successfully')
    end
  end

  describe "Session persistence" do
    before do
      post login_path, params: { email: 'test@example.com', password: 'password123' }
    end

    it "maintains session across requests" do
      get trader_dashboard_path
      expect(session[:user_id]).to eq(user.id)
    end

    it "allows access to protected pages when logged in" do
      get trader_dashboard_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "Protected routes" do
    it "redirects to login when accessing dashboard without session" do
      get trader_dashboard_path
      expect(response).to redirect_to(login_path)
    end
  end

  describe "Role-based redirects after login" do
    let(:pm_role) { Role.find_or_create_by(name: 'Portfolio Manager') }
    let(:portfolio_manager) do
      user = User.create!(
        email: 'pm@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        first_name: 'Manager',
        last_name: 'User'
      )
      user.roles << pm_role unless user.roles.exists?(id: pm_role.id)
      user
    end

    it "redirects Portfolio Manager to manager dashboard" do
      portfolio_manager.reload
      post login_path, params: { email: portfolio_manager.email, password: 'password123' }
      expect(response).to redirect_to(manager_dashboard_path)
    end

    it "redirects Trader to trader dashboard" do
      post login_path, params: { email: 'test@example.com', password: 'password123' }
      expect(response).to redirect_to(trader_dashboard_path)
    end
  end
end
