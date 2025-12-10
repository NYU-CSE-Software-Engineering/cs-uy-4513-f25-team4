Given('a trader exists with email {string} and balance {int}') do |email, balance|
  user = User.find_or_create_by!(email: email) do |u|
    u.first_name = "Test"
    u.last_name = "User"
    u.password = "password123"
    u.password_confirmation = "password123"
    u.role = "trader"
  end
  user.update!(balance: balance)
  @current_user = user
end

Given('a stock exists with symbol {string} price {float} and quantity {int}') do |symbol, price, qty|
  Stock.find_or_create_by!(symbol: symbol) do |s|
    s.name = symbol
    s.price = price
    s.available_quantity = qty
  end
end

Given('the trader owns {int} shares of {string}') do |qty, symbol|
  stock = Stock.find_by!(symbol: symbol)
  portfolio = Portfolio.find_or_initialize_by(user: @current_user, stock: stock)
  portfolio.quantity = (portfolio.quantity || 0) + qty
  portfolio.save!

  Transaction.create!(
    user: @current_user,
    stock: stock,
    quantity: qty,
    transaction_type: "buy",
    price: stock.price
  )
end

Given('that trader has a credit line with limit {int} and used {int}') do |limit, used|
  CreditLine.find_or_create_by!(user: @current_user) do |cl|
    cl.credit_limit = limit
    cl.credit_used = used
  end.update!(credit_limit: limit, credit_used: used)
end

Given('I am logged in as that trader') do
  visit login_path
  fill_in "Email", with: @current_user.email
  fill_in "Password", with: "password123"
  click_button "Log in"
end

When('I visit the credit line page') do
  visit credit_line_path
end
