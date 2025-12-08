Given("stock {string} was last updated {string}") do |symbol, time_ago_text|
  stock = Stock.find_by(symbol: symbol)
  
  # Parse time_ago_text like "5 minutes ago", "10 minutes ago", "2 hours ago"
  case time_ago_text
  when /(\d+) minute[s]? ago/
    minutes = $1.to_i
    stock.update(updated_at: minutes.minutes.ago)
  when /(\d+) hour[s]? ago/
    hours = $1.to_i
    stock.update(updated_at: hours.hours.ago)
  when "just now"
    stock.update(updated_at: Time.current)
  end
end

Then("I should see {string} for stock {string}") do |text, symbol|
  expect(page).to have_content(text)
  expect(page).to have_content(symbol)
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

When("I click the {string} button") do |button_text|
  click_button button_text
end

Then("the stock price should be updated") do
  # Check that the page has been refreshed or updated
  expect(page).to have_css('.stock-price', wait: 5)
end

Then("the {string} time should show {string}") do |label, time_text|
  expect(page).to have_content("#{label}: #{time_text}")
end

Given("an external stock data API is available") do
  # Mock API availability - in real implementation, this would check API status
  @api_available = true
end

Given("stock {string} has a current price of {string}") do |symbol, price|
  stock = Stock.find_by(symbol: symbol)
  stock.update(price: price.gsub('$', '').to_f)
end

When("the system fetches latest data from the API") do
  # Simulate API fetch - in real implementation, this would call the actual API
  @stocks_to_update = Stock.all
  @stocks_to_update.each do |stock|
    # Simulate price change (±2%)
    new_price = stock.price * (1 + rand(-0.02..0.02))
    stock.update(price: new_price)
    
    # Create new price point
    PricePoint.create!(
      stock: stock,
      price: new_price,
      recorded_at: Time.current
    )
  end
end

Then("stock {string} price should be updated to the latest value") do |symbol|
  stock = Stock.find_by(symbol: symbol)
  expect(stock.updated_at).to be >= 5.seconds.ago
end

Then("a new price point should be recorded") do
  expect(PricePoint.where('recorded_at >= ?', 5.seconds.ago).count).to be > 0
end

Then("the {string} timestamp should be current") do |field|
  stock = Stock.last
  case field
  when "updated_at"
    expect(stock.updated_at).to be >= 5.seconds.ago
  end
end

Given("stock {string} price was updated {string}") do |symbol, time_ago_text|
  stock = Stock.find_by(symbol: symbol)
  
  case time_ago_text
  when /(\d+) minute[s]? ago/
    minutes = $1.to_i
    stock.update(updated_at: minutes.minutes.ago)
  when /(\d+) hour[s]? ago/
    hours = $1.to_i
    stock.update(updated_at: hours.hours.ago)
  end
end

Then("I should see a {string} badge next to {string}") do |badge_text, symbol|
  # Look for the badge in the same row as the stock symbol
  within(:xpath, "//tr[contains(., '#{symbol}')]") do
    expect(page).to have_content(badge_text)
  end
end

Then("the badge should indicate {string}") do |text|
  expect(page).to have_content(text)
end

Then("I should see a warning {string}") do |warning_text|
  expect(page).to have_css('.warning, .alert-warning', text: warning_text)
end

Then("I should see a prominent {string} button") do |button_text|
  expect(page).to have_button(button_text)
end

Given("I am on the stock detail page for {string}") do |symbol|
  stock = Stock.find_by(symbol: symbol)
  visit stock_path(stock)
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

When("I wait for {int} seconds") do |seconds|
  sleep seconds
end

Given("the following stocks exist with outdated prices:") do |table|
  table.hashes.each do |row|
    stock = Stock.find_by(symbol: row['symbol'])
    stock.update(
      price: row['current_price'].to_f,
      updated_at: case row['last_updated']
                  when /(\d+) hour[s]? ago/
                    $1.to_i.hours.ago
                  when /(\d+) minute[s]? ago/
                    $1.to_i.minutes.ago
                  else
                    1.hour.ago
                  end
    )
  end
end

When("the scheduled stock price update job runs") do
  # Simulate the scheduled job running
  Stock.all.each do |stock|
    new_price = stock.price * (1 + rand(-0.02..0.02))
    stock.update(price: new_price, updated_at: Time.current)
    
    PricePoint.create!(
      stock: stock,
      price: new_price,
      recorded_at: Time.current
    )
  end
end

Then("all stock prices should be refreshed") do
  Stock.all.each do |stock|
    expect(stock.updated_at).to be >= 5.seconds.ago
  end
end

Then("new price points should be created for each stock") do
  recent_price_points = PricePoint.where('recorded_at >= ?', 10.seconds.ago)
  expect(recent_price_points.count).to be >= Stock.count
end

Then("each stock's {string} should be current") do |field|
  Stock.all.each do |stock|
    case field
    when "updated_at"
      expect(stock.updated_at).to be >= 5.seconds.ago
    end
  end
end

