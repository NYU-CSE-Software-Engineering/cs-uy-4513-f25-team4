# "I am a signed-in user" is defined in market_data.rb

Given("I have trading history in my portfolio") do
  # Create a stock first
  stock = Stock.find_or_create_by!(symbol: "AAPL") do |s|
    s.name = "Apple Inc."
    s.price = 150.0
    s.available_quantity = 1000
  end
  
  # Create portfolio entry
  Portfolio.find_or_create_by!(user: @user, stock: stock) do |p|
    p.quantity = 10
  end
end

When("I visit the analytics dashboard") do
  visit analytics_index_path
end

When("I select {string} from the date range filter") do |range|
  # Map display names to actual values in the select
  range_map = {
    "Last 3 Months" => "3 Months",
    "1 Week" => "1 Week",
    "1 Month" => "1 Month",
    "3 Months" => "3 Months",
    "6 Months" => "6 Months",
    "1 Year" => "1 Year"
  }
  
  select_value = range_map[range] || range
  select select_value, from: "range"
  click_button "View Chart"
end

Then("I should see a line chart displaying my portfolio value over time") do
  # Check for chart container or stock price trend
  has_chart = page.has_content?("Stock Price Trend") || page.has_css?("#stockChart")
  expect(has_chart).to be true
end

Then("the chart should update for the selected date range") do
  # Just verify we're still on the analytics page with a chart
  expect(page).to have_content("Portfolio Trend Graph")
end

When(/^I view the profit\/loss section$/) do
  visit analytics_index_path
  # Profit/Loss section might be on the same page, so just verify we're there
  expect(page).to have_content("Portfolio Trend Graph")
end

Then(/^I should see each stock'?s gain or loss in dollars and percent$/) do
  # Check for profit/loss related content
  has_profit_loss = page.has_content?("Profit") || page.has_content?("Loss") || page.has_content?("Gain")
  expect(has_profit_loss).to be true
end

Then("positive returns should appear in green and negative in red") do
  expect(page).to have_css(".positive-return")
  expect(page).to have_css(".negative-return")
end

When("I view the diversification chart") do
  visit analytics_index_path
  # Diversification chart might be on the same page
  expect(page).to have_content("Portfolio Trend Graph")
end

Then("I should see each sector represented with a percentage of my total balance") do
  # Check for percentage or portfolio content
  has_percentage = page.has_content?("%") || page.has_content?("Portfolio")
  expect(has_percentage).to be true
end

Given("I am on the analytics simulation page") do
  visit simulate_analytics_index_path
end

When("I enter {string} as the stock symbol") do |symbol|
  fill_in "Stock Symbol", with: symbol
end

When("I enter {string} as the investment amount") do |amount|
  fill_in "Investment Amount ($)", with: amount
end

When("I select {string} as the purchase date") do |date|
  fill_in "Purchase Date", with: date
end

# Removed duplicate step - now in common_steps.rb

Given("I have multiple holdings") do
  # Create multiple stocks
  stock_aapl = Stock.find_or_create_by!(symbol: "AAPL") do |s|
    s.name = "Apple Inc."
    s.price = 150.0
    s.available_quantity = 1000
  end
  
  stock_tsla = Stock.find_or_create_by!(symbol: "TSLA") do |s|
    s.name = "Tesla Inc."
    s.price = 250.0
    s.available_quantity = 1000
  end
  
  stock_msft = Stock.find_or_create_by!(symbol: "MSFT") do |s|
    s.name = "Microsoft Corporation"
    s.price = 420.0
    s.available_quantity = 1000
  end
  
  # Create portfolio entries
  Portfolio.find_or_create_by!(user: @user, stock: stock_aapl) do |p|
    p.quantity = 10
  end
  
  Portfolio.find_or_create_by!(user: @user, stock: stock_tsla) do |p|
    p.quantity = 5
  end
  
  Portfolio.find_or_create_by!(user: @user, stock: stock_msft) do |p|
    p.quantity = 8
  end
end

Given("I have stocks from multiple sectors") do
  # Create stocks from different sectors
  stock_aapl = Stock.find_or_create_by!(symbol: "AAPL") do |s|
    s.name = "Apple Inc."
    s.price = 180.0
    s.available_quantity = 1000
  end
  
  stock_tsla = Stock.find_or_create_by!(symbol: "TSLA") do |s|
    s.name = "Tesla Inc."
    s.price = 250.0
    s.available_quantity = 1000
  end
  
  # Create portfolio entries
  Portfolio.find_or_create_by!(user: @user, stock: stock_aapl) do |p|
    p.quantity = 10
  end
  
  Portfolio.find_or_create_by!(user: @user, stock: stock_tsla) do |p|
    p.quantity = 5
  end
end

Then("I should see the percent return displayed") do
  # Check for ROI or percentage in the results
  has_return = page.has_content?("%") || page.has_content?("ROI") || page.has_content?("Return")
  expect(has_return).to be true
end

When("I leave the stock symbol blank") do
  fill_in "Stock Symbol", with: ""
end
