require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /signup" do
    it "renders the new template" do
      get signup_path
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
    end
  end
  
  describe "GET /user_management" do
    it "renders the management template" do
      company = Company.create!(name: "Investra")
      User.create!(
        first_name: "Test",
        last_name: "User",
        email: "test@example.com",
        role: "Trader",
        company: company,
        password: "password",
        password_confirmation: "password"
      )
      
      get user_management_path
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:management)
    end
  end
  
  describe "GET /users/:id/edit" do
    it "renders the edit template" do
      company = Company.create!(name: "Investra")
      user = User.create!(
        first_name: "Test",
        last_name: "User",
        email: "test@example.com",
        role: "Trader",
        company: company,
        password: "password",
        password_confirmation: "password"
      )
      
      get edit_user_path(user)
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:edit)
    end
  end
  
  describe "POST /users" do
      it "creates a new user and redirects to the user's show page" do
          company = Company.create!(name: "Investra")
          user_params = {
            user: {
              first_name: "Alice",
              last_name: "Example",
              email: "alice#{SecureRandom.hex(3)}@example.com",
              role: "employee",
              company_id: company.id,
              password: "password",
              password_confirmation: "password"
            }
          }
          
          expect {
              post users_path, params: user_params
          }.to change(User, :count).by(1)
          
          user = User.last
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(user_path(user))
          expect(user.role).to eq("employee")
        end
    end
  
  describe "PATCH /users/:id" do
    it "updates the user's role, company, and manager" do
      company1 = Company.create!(name: "Company 1")
      company2 = Company.create!(name: "Company 2")
      
      manager = User.create!(
        first_name: "Manager",
        last_name: "User",
        email: "manager@test.com",
        role: "Portfolio Manager",
        company: company2,
        password: "password",
        password_confirmation: "password"
      )
      
      user = User.create!(
        first_name: "Employee",
        last_name: "User",
        email: "employee@test.com",
        role: "Trader",
        company: company1,
        password: "password",
        password_confirmation: "password"
      )
      
      patch user_path(user), params: {
        user: { 
          role: "Associate Trader",
          company: company2.name,
          manager: manager.email
        }
      }

      user.reload
      expect(user.role).to eq("Associate Trader")
      expect(user.company.name).to eq("Company 2")
      expect(user.manager.email).to eq("manager@test.com")
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(user_management_path)
    end
  end
  
  describe "PATCH /users/:id/assign_admin" do
    it "assigns the user as admin and redirects to the user's show page" do
      company = Company.create!(name: "Investra")
      
      user = User.create!(
        first_name: "Alice",
        last_name: "Example",
        email: "alice#{SecureRandom.hex(3)}@example.com",
        role: "employee",
        company: company,
        password: "password",
        password_confirmation: "password"
      )
      
      expect{
          patch assign_admin_user_path(user)
      }.to change {user.reload.role}.from("employee").to("admin")
      
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(user_path(user))
    end
  end
  
  describe "PATCH /users/:id/update_role" do
    it "updates the user's role and redirects to the user management page" do
      company = Company.create!(name: "Investra")
      user = User.create!(
        first_name: "Employee",
        last_name: "User",
        email: "employee@test.com",
        role: "Employee",
        company: company,
        password: "password",
        password_confirmation: "password"
      )
      patch update_role_user_path(user), params: {
        user: { role: "Portfolio Manager" }
      }

      user.reload
      expect(user.role).to eq("Portfolio Manager")
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(user_management_path)
    end
  end
end
