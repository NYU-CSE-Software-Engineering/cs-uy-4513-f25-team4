Given("I am a signed-in user") do
  @user = User.create!(email: "test@example.com", password: "password")
  visit new_user_session_path
  fill_in "Email", with: @user.email
  fill_in "Password", with: @user.password
  click_button "Log in"
end

Given("I have trading history in my portfolio") do
  @portfolio = Portfolio.create!(user: @user, name: "Main Portfolio")
  @portfolio.holdings.create!(symbol: "AAPL", quantity: 10, average_price: 
150)
end

When("I visit the analytics dashboard") do
  visit analytics_index_path
end

When("I select {string} from the date range filter") do |range|
  select range, from: "date_range"
  click_button "Update Chart"
end

Then("I should see a line chart displaying my portfolio value over time") do
  expect(page).to have_content("Portfolio Value Over Time")
end

Then("the chart should update for the selected date range") do
  expect(page).to have_content("Showing data for Last 3 Months")
end

When("I view the profit/loss section") do
  visit analytics_index_path
  click_link "Profit/Loss Summary"
end

Then("I should see each stock’s gain or loss in dollars and percent") do
  expect(page).to have_content("Gain/Loss")
end

Then("positive returns should appear in green and negative in red") do
  expect(page).to have_css(".positive-return")
  expect(page).to have_css(".negative-return")
end

When("I view the diversification chart") do
  visit analytics_index_path
  click_link "Diversification"
end

Then("I should see each sector represented with a percentage of my total 
balance") do
  expect(page).to have_content("% of Total Portfolio")
end

Given("I am on the analytics simulation page") do
  visit simulate_analytics_index_path
end

When("I enter {string} as the stock symbol") do |symbol|
  fill_in "Symbol", with: symbol
end

When("I enter {string} as the investment amount") do |amount|
  fill_in "Amount", with: amount
end

When("I select {string} as the purchase date") do |date|
  fill_in "Date", with: date
end



# Removed duplicate step - now in common_steps.rb

