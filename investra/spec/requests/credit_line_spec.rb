require "rails_helper"

RSpec.describe "CreditLine", type: :request do
  let(:user) do
    User.create!(
      email: "credit@example.com",
      first_name: "Credit",
      last_name: "User",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    CreditLine.create!(user: user, credit_limit: 10_000, credit_used: 2_500)
  end

  it "returns credit line summary" do
    get "/credit_line"

    expect(response).to have_http_status(:ok)
    payload = JSON.parse(response.body)
    expect(payload["credit_limit"]).to eq(10_000.0)
    expect(payload["available_balance"]).to eq(7_500.0)
  end
end
