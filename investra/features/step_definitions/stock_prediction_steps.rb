Given("stock {string} has {int} days of historical price data") do |symbol, days|
  stock = Stock.find_by(symbol: symbol)
  days.times do |i|
    PricePoint.create!(
      stock: stock,
      price: stock.price + rand(-5.0..5.0),
      recorded_at: (Date.current - (days - i).days).beginning_of_day + 9.hours
    )
  end
end

Given("stock {string} has increasing price trend over {int} days") do |symbol, days|
  stock = Stock.find_by(symbol: symbol)
  base_price = stock.price - 20.0
  days.times do |i|
    PricePoint.create!(
      stock: stock,
      price: base_price + (i * 0.8) + rand(-1.0..1.0),
      recorded_at: (Date.current - (days - i).days).beginning_of_day + 9.hours
    )
  end
end

Given("stock {string} has decreasing price trend over {int} days") do |symbol, days|
  stock = Stock.find_by(symbol: symbol)
  base_price = stock.price + 20.0
  days.times do |i|
    PricePoint.create!(
      stock: stock,
      price: base_price - (i * 0.8) + rand(-1.0..1.0),
      recorded_at: (Date.current - (days - i).days).beginning_of_day + 9.hours
    )
  end
end

Given("stock {string} has only {int} days of historical data") do |symbol, days|
  stock = Stock.find_by(symbol: symbol)
  days.times do |i|
    PricePoint.create!(
      stock: stock,
      price: stock.price + rand(-2.0..2.0),
      recorded_at: (Date.current - (days - i).days).beginning_of_day + 9.hours
    )
  end
end

Then("I should see predicted price for next day") do
  # Wait a bit for JavaScript to load
  sleep(0.5)
  
  # Click generate prediction button using JavaScript execution
  page.execute_script("document.getElementById('generate-prediction-btn').click()")
  
  # Wait for result to appear (up to 15 seconds including backend processing)
  expect(page).to have_css('#prediction-result', visible: true, wait: 15)
  
  within('#prediction-result') do
    expect(page).to have_css('#predicted-price')
    expect(page.find('#predicted-price').text).to match(/\$\d+\.\d{2}/)
  end
end

Then("I should see prediction confidence level") do
  # Button already clicked in previous step, just verify
  within('#prediction-result') do
    expect(page).to have_content('Confidence')
    expect(page.find('#confidence-value').text).to match(/\d+(\.\d+)?%/)
  end
end

Then("the predicted price should indicate an upward trend") do
  # Wait a bit for JavaScript to load
  sleep(0.5)
  
  # Click using JavaScript execution
  page.execute_script("document.getElementById('generate-prediction-btn').click()")
  
  # Wait for result to appear
  expect(page).to have_css('#prediction-result', visible: true, wait: 15)
  
  within('#prediction-result') do
    expect(page).to have_css('.prediction-trend.upward')
  end
end

Then("the predicted price should indicate a downward trend") do
  # Wait a bit for JavaScript to load
  sleep(0.5)
  
  # Click using JavaScript execution
  page.execute_script("document.getElementById('generate-prediction-btn').click()")
  
  # Wait for result to appear
  expect(page).to have_css('#prediction-result', visible: true, wait: 15)
  
  within('#prediction-result') do
    expect(page).to have_css('.prediction-trend.downward')
  end
end

Then("I should not see predicted price") do
  # Wait a bit for JavaScript to load
  sleep(0.5)
  
  # Click using JavaScript execution - should show error for insufficient data
  page.execute_script("document.getElementById('generate-prediction-btn').click()")
  
  # Wait for error to appear
  expect(page).to have_css('#prediction-error', visible: true, wait: 15)
  expect(page).not_to have_css('#prediction-result', visible: true)
  
  # Verify error message is visible
  within('#prediction-error') do
    expect(page).to have_content('Insufficient data', visible: true)
  end
end

Then("I should see {string} with a dollar amount") do |label|
  # Click generate prediction button first if not already clicked
  if page.has_css?('#prediction-initial', visible: true)
    sleep(0.5)
    page.execute_script("document.getElementById('generate-prediction-btn').click()")
    expect(page).to have_css('#prediction-result', visible: true, wait: 15)
  end
  
  within('#prediction-result') do
    expect(page).to have_content(label)
    case label
    when "Predicted Price"
      expect(page.find('#predicted-price').text).to match(/\$\d+\.\d{2}/)
    end
  end
end

Then("I should see {string} percentage") do |label|
  # Result should already be visible from previous step
  within('#prediction-result') do
    expect(page).to have_content(label)
    case label
    when "Confidence"
      expect(page.find('#confidence-value').text).to match(/\d+(\.\d+)?%/)
    end
  end
end

Then("I should see {string} with number of data points") do |label|
  # Result should already be visible from previous step
  within('#prediction-result') do
    expect(page).to have_content(label)
    expect(page.find('#data-points-info').text).to match(/\d+ data points/)
  end
end

Then("I should see {string} with a percentage") do |label|
  # Result should already be visible from previous step
  within('#prediction-result') do
    expect(page).to have_content(label)
    if label == "Confidence"
      expect(page.find('#confidence-value').text).to match(/\d+(\.\d+)?%/)
    end
  end
end

