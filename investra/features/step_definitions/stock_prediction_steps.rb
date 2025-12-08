Given("stock {string} has {int} days of historical price data") do |symbol, days|
  stock = Stock.find_by(symbol: symbol)
  days.times do |i|
    PricePoint.create!(
      stock: stock,
      price: stock.price + rand(-5.0..5.0),
      recorded_at: (Date.current - (days - i).days).beginning_of_day + 9.hours
    )
  end
  
  # Click generate prediction button and wait for results
  click_button 'Generate Prediction'
  expect(page).to have_css('#prediction-result', visible: true, wait: 5)
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
  
  # Click generate prediction button and wait for results
  click_button 'Generate Prediction'
  expect(page).to have_css('#prediction-result', visible: true, wait: 5)
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
  
  # Click generate prediction button and wait for results
  click_button 'Generate Prediction'
  expect(page).to have_css('#prediction-result', visible: true, wait: 5)
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
  
  # Click generate prediction button - should show error
  click_button 'Generate Prediction'
  expect(page).to have_css('#prediction-error', visible: true, wait: 5)
end

Then("I should see predicted price for next day") do
  within('#prediction-result') do
    expect(page).to have_css('#predicted-price', wait: 3)
    expect(page.find('#predicted-price').text).to match(/\$\d+\.\d{2}/)
  end
end

Then("I should see prediction confidence level") do
  within('#prediction-result') do
    expect(page).to have_content('Confidence', wait: 3)
    expect(page.find('#confidence-value').text).to match(/\d+(\.\d+)?%/)
  end
end

Then("the predicted price should indicate an upward trend") do
  within('#prediction-result') do
    expect(page).to have_css('.prediction-trend.upward', wait: 3)
  end
end

Then("the predicted price should indicate a downward trend") do
  within('#prediction-result') do
    expect(page).to have_css('.prediction-trend.downward', wait: 3)
  end
end

Then("I should not see predicted price") do
  expect(page).to have_css('#prediction-error', visible: true, wait: 3)
  expect(page).not_to have_css('#prediction-result', visible: true)
end

Then("I should see {string} with a dollar amount") do |label|
  within('#prediction-result') do
    expect(page).to have_content(label, wait: 3)
    case label
    when "Predicted Price"
      expect(page.find('#predicted-price').text).to match(/\$\d+\.\d{2}/)
    end
  end
end

Then("I should see {string} percentage") do |label|
  within('#prediction-result') do
    expect(page).to have_content(label, wait: 3)
    case label
    when "Confidence"
      expect(page.find('#confidence-value').text).to match(/\d+(\.\d+)?%/)
    end
  end
end

Then("I should see {string} with number of data points") do |label|
  within('#prediction-result') do
    expect(page).to have_content(label, wait: 3)
    expect(page.find('#data-points-info').text).to match(/\d+ data points/)
  end
end

Then("I should see {string} with a percentage") do |label|
  within('#prediction-result') do
    expect(page).to have_content(label, wait: 3)
    if label == "Confidence"
      expect(page.find('#confidence-value').text).to match(/\d+(\.\d+)?%/)
    end
  end
end

