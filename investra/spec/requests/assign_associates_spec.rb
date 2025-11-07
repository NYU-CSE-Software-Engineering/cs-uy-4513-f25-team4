require 'rails_helper'

RSpec.describe "AssignAssociates", type: :request do
  describe "PATCH /users/:id/assign_associate" do
    let!(:company) { Company.create!(name: "Investra Capital") }
    let!(:user) do
      User.create!(
        email: "jane@example.com",
        first_name: "Jane",
        last_name: "Doe",
        role: "unassigned",
        password: "password",
        password_confirmation: "password",
        company: nil
      )
    end

    context "when the company_id is valid" do
      it "assigns the user and redirects with success" do
        patch "/users/#{user.id}/assign_associate", params: { company_id: company.id }

        expect(response).to redirect_to(user_management_path)
        follow_redirect!
        expect(response.body).to include("User assigned to company successfully")
        expect(user.reload.company).to eq(company)
      end
    end

    context "when the company_id is invalid" do
      it "redirects with failure and does not update the user" do
        patch "/users/#{user.id}/assign_associate", params: { company_id: -1 }

        expect(response).to redirect_to(user_management_path)
        follow_redirect!
        expect(response.body).to include("Failed to assign user")
        expect(user.reload.company).to be_nil
      end
    end
  end
end

