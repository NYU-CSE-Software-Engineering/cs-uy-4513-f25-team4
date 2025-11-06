require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /signup" do
    it "renders the new template" do
      get signup_path
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
    end
  end
  describe "POST /users" do
      it "creates a new user and redirects to the user's show page" do
          company = Company.create!(name: "TestCorp")

          user_params = {
              user: {
              first_name: "Alice",
              last_name: "Example",
              email: "alice#{SecureRandom.hex(4)}@example.com",
              role: "employee",
              company_id: company.id
              }
          }
          expect {
            post users_path, params: user_params
          }.to change(User, :count).by(1)
        
          expect(response).to have_http_status(:found) # 302 redirect
          expect(response).to redirect_to(assigns(:user))
        end
    end
end
