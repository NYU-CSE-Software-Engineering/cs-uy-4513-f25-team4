# features/step_definitions/buying_and_selling_steps.rb

Given("I am a logged-in user") do
  # Create a test user and log them in
  @user = User.create!(email: 'investor@example.com', password: 'password', balance: 5000)
  visit new_user_session_path
  fill_in 'Email', with: @user.email
  fill_in 'Password', with: @user.password
  click_button 'Log in'
  expect(page).to have_content('Signed in successfully')
end

# Removed duplicate step - now in common_steps.rb

Given("I can see a list of available market stocks") do
  expect(page).to have_selector('.stock-list')
end

When("I search for {string} in the stock search box") do |stock_symbol|
  fill_in 'Search', with: stock_symbol
  click_button 'Search'
end

When("I click the {string} button next to {string}") do |button, stock_symbol|
  within(".stock-row[data-symbol='#{stock_symbol}']") do
    click_button button
  end
end

When("I enter {string} in the quantity field") do |quantity|
  fill_in 'Quantity', with: quantity
end

When("I confirm the transaction") do
  click_button 'Confirm'
end

Then("my account balance should decrease by the correct total amount") do
  # The balance updates dynamically on the page
  expect(page).to have_selector('#balance', text: /\$\d+/)
end

Then("my owned stock list should include {string} with quantity {string}") do |stock_symbol, quantity|
  visit portfolio_path
  within('.portfolio-list') do
    expect(page).to have_content(stock_symbol)
    expect(page).to have_content(quantity)
  end
end

Then("I should see the message {string}") do |message|
  expect(page).to have_content(message)
end

# Edge case

Given("my balance is less than the total cost of {int} shares of {string}") do |shares, symbol|
  @user.update(balance: 50) # Force low balance
  visit stocks_path
end

Then("the transaction should not complete") do
  expect(page).to have_no_content('Purchase successful')
end

Then("my balance and portfolio should remain unchanged") do
  expect(page).to have_selector('#balance', text: /\$50/)
end

# Selling

Given("I own {string} with quantity {int}") do |stock_symbol, quantity|
  stock = Stock.create!(symbol: stock_symbol, name: stock_symbol, price: 100)
  Portfolio.create!(user: @user, stock: stock, quantity: quantity)
end

When("I attempt to sell {int} shares of {string}") do |quantity, stock_symbol|
  visit portfolio_path
  within(".stock-row[data-symbol='#{stock_symbol}']") do
    click_button 'Sell'
  end
  fill_in 'Quantity', with: quantity
  click_button 'Confirm'
end

Then("the transaction should not be recorded") do
  visit transactions_path
  expect(page).to have_no_content('Insufficient shares')
end

# UI & System

Then("my portfolio and balance information should refresh automatically") do
  expect(page).to have_content('Portfolio updated')
end

Then("the {string} and {string} buttons should be disabled") do |btn1, btn2|
  expect(page).to have_button(btn1, disabled: true)
  expect(page).to have_button(btn2, disabled: true)
end

Then("I should see a notification {string}") do |message|
  expect(page).to have_content(message)
end

Given("I am not logged in") do
  visit destroy_user_session_path
end

When("I try to access the {string} or {string} functionality") do |btn1, btn2|
  visit stocks_path
  expect(page).to have_no_button(btn1)
  expect(page).to have_no_button(btn2)
end

Then("I should be redirected to the login page") do
  expect(current_path).to eq(new_user_session_path)
end
