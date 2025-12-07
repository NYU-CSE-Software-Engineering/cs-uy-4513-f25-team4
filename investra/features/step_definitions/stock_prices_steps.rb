# Step definitions for checking real-time and historical stock prices

Given("the following stocks exist with price history:") do |table|
  table.hashes.each do |row|
    Stock.create!(
      symbol: row['symbol'],
      name: row['name'],
      price: row['current_price'].to_f,
      available_quantity: 1000,
      sector: 'Technology',
      market_cap: 1000000000,
      description: 'A leading company'
    )
  end
end

Then("I should see {string} with current price {string}") do |symbol, price|
  within('.stock-list') do
    stock_row = find('.stock-row', text: symbol)
    expect(stock_row).to have_content(price)
  end
end

Then("I should see {string} followed by a timestamp") do |text|
  expect(page).to have_content(text)
  # Verify timestamp format (e.g., "2025-12-07 10:30:00" or "5 minutes ago")
  expect(page.text).to match(/#{Regexp.escape(text)}\s+(\d{4}-\d{2}-\d{2}|\d+\s+(minute|hour|day)s?\s+ago)/i)
end

Given("stock {string} has the following price history:") do |symbol, table|
  stock = Stock.find_by(symbol: symbol)
  table.hashes.each do |row|
    PricePoint.create!(
      stock: stock,
      price: row['price'].to_f,
      recorded_at: DateTime.parse(row['recorded_at'])
    )
  end
end

Then("I should see a price history table") do
  expect(page).to have_selector('table.price-history')
end

Then("I should see the following prices in order:") do |table|
  within('table.price-history') do
    table.hashes.each_with_index do |row, index|
      row_element = all('tbody tr')[index]
      expect(row_element).to have_content(row['Date'])
      expect(row_element).to have_content(row['Price'])
    end
  end
end

Given("stock {string} has daily prices for the last {int} days") do |symbol, days|
  stock = Stock.find_by(symbol: symbol)
  days.times do |i|
    PricePoint.create!(
      stock: stock,
      price: rand(130.0..150.0).round(2),
      recorded_at: (days - i).days.ago
    )
  end
end

Then("I should see {string} followed by a price") do |text|
  expect(page).to have_content(text)
  expect(page.text).to match(/#{Regexp.escape(text)}\s+\$\d+\.\d{2}/)
end

Given("stock {string} had a closing price of {string} yesterday") do |symbol, price|
  stock = Stock.find_by(symbol: symbol)
  PricePoint.create!(
    stock: stock,
    price: price.gsub('$', '').to_f,
    recorded_at: 1.day.ago.end_of_day
  )
end

Given("stock {string} has current price of {string}") do |symbol, price|
  stock = Stock.find_by(symbol: symbol)
  stock.update!(price: price.gsub('$', '').to_f)
end

Then("I should see {string} with price change {string}") do |symbol, change_text|
  within('.stock-list') do
    stock_row = find('.stock-row', text: symbol)
    expect(stock_row).to have_content(change_text)
  end
end

Then("the price change should be displayed in green") do
  # Check for positive price change styling
  expect(page).to have_css('.price-change.positive, .text-success')
end

Given("stock {string} price was last updated {string}") do |symbol, time_ago|
  stock = Stock.find_by(symbol: symbol)
  # Store the updated_at timestamp
  time_value = case time_ago
  when /(\d+) minutes? ago/
    $1.to_i.minutes.ago
  when /(\d+) hours? ago/
    $1.to_i.hours.ago
  else
    5.minutes.ago
  end
  stock.update!(updated_at: time_value)
end

