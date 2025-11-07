require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:password_attrs) { { password: 'password', password_confirmation: 'password' } }

  describe "GET /signup" do
    it "renders the new template" do
      get signup_path
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
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
              company_id: company.id
            }.merge(password_attrs)
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
  
  
  describe "PATCH /users/:id/assign_admin" do
    it "assigns the user as admin and redirects to the user's show page" do
      company = Company.create!(name: "Investra")
      
      user = User.create!(
        {
          first_name: "Alice",
          last_name: "Example",
          email: "alice#{SecureRandom.hex(3)}@example.com",
          role: "employee",
          company: company
        }.merge(password_attrs)
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
        {
          first_name: "Employee",
          last_name: "User",
          email: "employee@test.com",
          role: "Employee",
          company: company
        }.merge(password_attrs)
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
