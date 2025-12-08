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
  # Click generate prediction button first using CSS selector
  find('#generate-prediction-btn').click
  expect(page).to have_css('#prediction-result', visible: true, wait: 5)
  
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
  # Click generate prediction button first using CSS selector
  find('#generate-prediction-btn').click
  expect(page).to have_css('#prediction-result', visible: true, wait: 5)
  
  within('#prediction-result') do
    expect(page).to have_css('.prediction-trend.upward')
  end
end

Then("the predicted price should indicate a downward trend") do
  # Click generate prediction button first using CSS selector
  find('#generate-prediction-btn').click
  expect(page).to have_css('#prediction-result', visible: true, wait: 5)
  
  within('#prediction-result') do
    expect(page).to have_css('.prediction-trend.downward')
  end
end

Then("I should not see predicted price") do
  # Click generate prediction button - should show error for insufficient data
  find('#generate-prediction-btn').click
  expect(page).to have_css('#prediction-error', visible: true, wait: 5)
  expect(page).not_to have_css('#prediction-result', visible: true)
end

Then("I should see {string} with a dollar amount") do |label|
  # Click generate prediction button first if not already clicked
  if page.has_css?('#prediction-initial', visible: true)
    find('#generate-prediction-btn').click
    expect(page).to have_css('#prediction-result', visible: true, wait: 5)
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

