Given("I am logged in as a trader") do
  @user = User.create!(
    email: 'trader@test.com',
    first_name: 'Test',
    last_name: 'Trader',
    role: 'Trader',
    password: 'password',
    password_confirmation: 'password',
    company: Company.find_or_create_by!(name: 'Test Company')
  )
  visit '/login'
  fill_in 'Email', with: @user.email
  fill_in 'Password', with: 'password'
  click_button 'Log in'
end

Given("the following stocks exist:") do |table|
  table.hashes.each do |row|
    Stock.create!(
      symbol: row['symbol'],
      name: row['name'],
      price: row['price'].to_f,
      available_quantity: 1000
    )
  end
end

When("I visit the stocks page") do
  visit stocks_path
end

Given("stock {string} has the following company information:") do |symbol, table|
  stock = Stock.find_by(symbol: symbol)
  data = table.rows_hash
  stock.update!(
    sector: data['sector'],
    market_cap: data['market_cap'].to_f
  )
end

When("I click on {string}") do |link_text|
  click_link link_text
end

Given("stock {string} has the following news articles:") do |symbol, table|
  stock = Stock.find_by(symbol: symbol)
  table.hashes.each do |row|
    News.create!(
      stock: stock,
      title: row['title'],
      published_at: DateTime.parse(row['published_at']),
      source: row['source']
    )
  end
end

