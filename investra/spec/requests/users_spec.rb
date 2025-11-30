require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:password_attrs) { { password: 'password123', password_confirmation: 'password123' } }
  
  describe "GET /signup" do
    it "renders the new template" do
      get signup_path
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
    end
  end
  
  describe "POST /signup" do
    it "creates a new user with role and redirects to dashboard" do
      # Create the Trader role first
      Role.create!(name: "Trader", description: "Individual investor")
      
      user_params = {
        user: {
          first_name: "Alice",
          last_name: "Example",
          email: "alice#{SecureRandom.hex(3)}@example.com"
        }.merge(password_attrs),
        role_name: "Trader"
      }
      
      expect {
        post signup_path, params: user_params
      }.to change(User, :count).by(1)
      
      user = User.last
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to('/dashboard/trader')
      expect(user.roles.pluck(:name)).to include("Trader")
    end
  end
  
  describe "PATCH /users/:id/assign_admin" do
    it "assigns the user as admin and redirects to the user's show page" do
      company = Company.create!(name: "Investra")
      user = User.create!(
        {
          first_name: "Alice",
          last_name: "Example",
          email: "alice#{SecureRandom.hex(3)}@example.com",
          company: company
        }.merge(password_attrs)
      )
      
      expect {
        patch assign_admin_user_path(user)
      }.to change { user.reload.role }.from(nil).to("admin")
      
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(user_path(user))
    end
  end
  
  describe "PATCH /users/:id/update_role" do
    it "updates the user's role and redirects to the user management page" do
      company = Company.create!(name: "Investra")
      user = User.create!(
        {
          first_name: "Employee",
          last_name: "User",
          email: "employee@test.com",
          company: company
        }.merge(password_attrs)
      )
      # Assign initial role
      employee_role = Role.find_or_create_by(name: "Employee")
      user.roles << employee_role
      
      patch update_role_user_path(user), params: {
        user: { role: "Portfolio Manager" }
      }
      
      user.reload
      expect(user.roles.first.name).to eq("Portfolio Manager")
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(user_management_path)
    end
  end
end
