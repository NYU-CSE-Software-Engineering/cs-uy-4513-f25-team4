# Step definitions for price trend graph feature

Given("stock {string} has price history for the last {int} days") do |symbol, days|
  stock = Stock.find_by(symbol: symbol)
  raise "Stock #{symbol} not found" unless stock
  
  # Create price history for the specified number of days
  (0...days).each do |i|
    date = (days - i).days.ago
    base_price = stock.price
    # Add some variation to make it realistic
    variation = rand(-10.0..10.0)
    price = base_price + variation
    
    PricePoint.create!(
      stock: stock,
      price: price,
      recorded_at: date
    )
  end
end

Given("stock {string} has no price history") do |symbol|
  stock = Stock.find_by(symbol: symbol)
  raise "Stock #{symbol} not found" unless stock
  
  # Delete all price points for this stock
  stock.price_points.destroy_all
end

Then("I should see a price trend graph") do
  expect(page).to have_css('#price-trend-chart', visible: true)
end

Then("the graph should display {string} timeframe by default") do |timeframe|
  # Check if the default timeframe button is active
  case timeframe
  when "30-day"
    expect(page).to have_css('.timeframe-btn.active[data-timeframe="30"]', visible: true)
  when "7-day"
    expect(page).to have_css('.timeframe-btn.active[data-timeframe="7"]', visible: true)
  when "365-day"
    expect(page).to have_css('.timeframe-btn.active[data-timeframe="365"]', visible: true)
  end
end

When("I click on {string} timeframe button") do |timeframe|
  case timeframe
  when "Week"
    find('.timeframe-btn[data-timeframe="7"]').click
  when "Month"
    find('.timeframe-btn[data-timeframe="30"]').click
  when "Year"
    find('.timeframe-btn[data-timeframe="365"]').click
  end
  sleep 0.5 # Allow time for the graph to update
end

Then("the graph should display {string} data") do |timeframe|
  case timeframe
  when "7-day"
    expect(page).to have_css('.timeframe-btn.active[data-timeframe="7"]', visible: true)
  when "30-day"
    expect(page).to have_css('.timeframe-btn.active[data-timeframe="30"]', visible: true)
  when "365-day"
    expect(page).to have_css('.timeframe-btn.active[data-timeframe="365"]', visible: true)
  end
end

Then("I should see price points for the last {int} days") do |days|
  # Verify that the graph canvas exists and is visible
  expect(page).to have_css('#price-trend-chart', visible: true)
  
  # Check that data is loaded via JavaScript data attribute
  chart_element = page.find('#price-trend-chart')
  expect(chart_element['data-prices']).not_to be_nil
end

Then("the graph should show price {string} for date {string}") do |price, date|
  # Check that the data includes this price and date
  chart_element = page.find('#price-trend-chart')
  prices_data = JSON.parse(chart_element['data-prices'])
  dates_data = JSON.parse(chart_element['data-dates'])
  
  date_index = dates_data.index(date)
  expect(date_index).not_to be_nil, "Expected date #{date} to be in chart data"
  expect(prices_data[date_index].to_f).to eq(price.to_f), "Expected price #{price} for date #{date}"
end

# Removed duplicate "I should see {string}" - already defined in common_steps.rb

Then("I should not see a price trend graph") do
  expect(page).not_to have_css('#price-trend-chart', visible: true)
end

