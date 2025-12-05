require "rails_helper"

RSpec.describe "Watchlists", type: :request do
  let(:user) do
    User.create!(
      email: "watcher@example.com",
      first_name: "Watch",
      last_name: "User",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  it "adds a symbol to the watchlist" do
    post "/watchlist", params: { symbol: "MSFT" }, headers: { "ACCEPT" => "application/json" }

    expect(response).to have_http_status(:created)
    expect(JSON.parse(response.body)["symbol"]).to eq("MSFT")
  end

  it "lists watched symbols" do
    user.watchlists.create!(symbol: "MSFT")
    get "/watchlist", headers: { "ACCEPT" => "application/json" }

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["symbols"]).to include("MSFT")
  end

  it "removes a symbol from the watchlist" do
    user.watchlists.create!(symbol: "MSFT")

    delete "/watchlist/MSFT", headers: { "ACCEPT" => "application/json" }
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["removed"]).to eq(true)
  end
end
