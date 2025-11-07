require 'rails_helper'

RSpec.describe "AssignAssociates", type: :request do
  describe "PATCH /users/:id/assign_associate" do
    let!(:company) { Company.create!(name: "Investra Capital") }
    let(:password_attrs) { { password: 'password', password_confirmation: 'password' } }
    let!(:user) do
      User.create!(
        {
          email: "jane@example.com",
          first_name: "Jane",
          last_name: "Doe",
          role: "unassigned",
          company: nil
        }.merge(password_attrs)
      )
    end


    it "assigns the user to the specified company and redirects to the user management page" do
      patch "/users/#{user.id}/assign_associate", params: { company_id: company.id }

      expect(response).to redirect_to(user_management_path)
      follow_redirect!
      expect(response.body).to include("User assigned to company successfully")
      expect(user.reload.company).to eq(company)
    end
  end
end
