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
  expect(page).to have_css('.prediction-price', wait: 3)
  expect(page.text).to match(/\$\d+\.\d{2}/)
end

Then("I should see prediction confidence level") do
  expect(page).to have_content('Confidence')
  expect(page.text).to match(/\d+(\.\d+)?%/)
end

Then("the predicted price should indicate an upward trend") do
  expect(page).to have_css('.prediction-trend.upward', wait: 3)
end

Then("the predicted price should indicate a downward trend") do
  expect(page).to have_css('.prediction-trend.downward', wait: 3)
end

Then("I should not see predicted price") do
  expect(page).not_to have_css('.prediction-price')
end

Then("I should see {string} with a dollar amount") do |label|
  expect(page).to have_content(label)
  expect(page.text).to match(/#{label}.*\$\d+\.\d{2}/)
end

Then("I should see {string} percentage") do |label|
  expect(page).to have_content(label)
  expect(page.text).to match(/#{label}.*\d+(\.\d+)?%/)
end

Then("I should see {string} with number of data points") do |label|
  expect(page).to have_content(label)
  expect(page.text).to match(/#{label}.*\d+/)
end

Then("I should see {string} with a percentage") do |label|
  expect(page).to have_content(label)
  expect(page.text).to match(/#{label}.*\d+(\.\d+)?%/)
end

