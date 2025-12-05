require "rails_helper"

RSpec.describe "Portfolios", type: :request do
  let(:user) do
    User.create!(
      email: "trader@example.com",
      first_name: "Trade",
      last_name: "User",
      password: "password123",
      password_confirmation: "password123"
    )
  end
  let(:stock) { Stock.create!(symbol: "AAPL", name: "Apple", price: 150.00, available_quantity: 1_000) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    Portfolio.create!(user: user, stock: stock, quantity: 10)
    Transaction.create!(user: user, stock: stock, quantity: 10, transaction_type: "buy", price: 120.00)
  end

  it "returns a portfolio summary with holdings" do
    get "/portfolio"

    expect(response).to have_http_status(:ok)
    payload = JSON.parse(response.body)

    expect(payload["holdings"].size).to eq(1)
    holding = payload["holdings"].first
    expect(holding["symbol"]).to eq("AAPL")
    expect(payload["total_value"]).to be_a(Float)
  end
end
