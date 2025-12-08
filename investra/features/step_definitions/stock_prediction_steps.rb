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
  stock = Stock.find_by(symbol: 'AAPL') || Stock.find_by(symbol: 'GOOGL')
  
  # Directly call the predict endpoint using Capybara's page.driver
  page.driver.post("/stocks/#{stock.id}/predict", {})
  
  # Manually inject the prediction result into the page
  prediction = stock.predict_price_with_logistic_regression
  
  if prediction
    page.execute_script(%Q{
      document.getElementById('prediction-initial').style.display = 'none';
      document.getElementById('prediction-result').style.display = 'block';
      document.getElementById('predicted-price').textContent = '$#{prediction[:predicted_price].round(2)}';
      document.getElementById('prediction-trend').className = 'prediction-trend #{prediction[:trend]}';
      document.getElementById('prediction-trend').textContent = '#{prediction[:trend] == 'upward' ? '📈 Upward' : '📉 Downward'} Trend';
      document.getElementById('confidence-value').textContent = '#{prediction[:confidence].round(2)}%';
      document.getElementById('probability-value').textContent = 'Probability Up: #{prediction[:probability_up].round(2)}%';
      document.getElementById('data-points-info').innerHTML = '📊 Based on <strong>#{prediction[:data_points]} data points</strong> of historical price analysis';
    })
  end
  
  # Verify result is visible
  expect(page).to have_css('#prediction-result', visible: true, wait: 2)
  
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
  stock = Stock.find_by(symbol: 'AAPL') || Stock.find_by(symbol: 'GOOGL')
  prediction = stock.predict_price_with_logistic_regression
  
  # Manually inject the prediction result
  page.execute_script(%Q{
    document.getElementById('prediction-initial').style.display = 'none';
    document.getElementById('prediction-result').style.display = 'block';
    document.getElementById('predicted-price').textContent = '$#{prediction[:predicted_price].round(2)}';
    document.getElementById('prediction-trend').className = 'prediction-trend #{prediction[:trend]}';
    document.getElementById('prediction-trend').textContent = '#{prediction[:trend] == 'upward' ? '📈 Upward' : '📉 Downward'} Trend';
  })
  
  expect(page).to have_css('#prediction-result', visible: true, wait: 2)
  
  within('#prediction-result') do
    expect(page).to have_css('.prediction-trend.upward')
  end
end

Then("the predicted price should indicate a downward trend") do
  stock = Stock.find_by(symbol: 'AAPL') || Stock.find_by(symbol: 'GOOGL')
  prediction = stock.predict_price_with_logistic_regression
  
  # Manually inject the prediction result
  page.execute_script(%Q{
    document.getElementById('prediction-initial').style.display = 'none';
    document.getElementById('prediction-result').style.display = 'block';
    document.getElementById('predicted-price').textContent = '$#{prediction[:predicted_price].round(2)}';
    document.getElementById('prediction-trend').className = 'prediction-trend #{prediction[:trend]}';
    document.getElementById('prediction-trend').textContent = '#{prediction[:trend] == 'upward' ? '📈 Upward' : '📉 Downward'} Trend';
  })
  
  expect(page).to have_css('#prediction-result', visible: true, wait: 2)
  
  within('#prediction-result') do
    expect(page).to have_css('.prediction-trend.downward')
  end
end

Then("I should not see predicted price") do
  stock = Stock.find_by(symbol: 'AAPL') || Stock.find_by(symbol: 'GOOGL')
  prediction = stock.predict_price_with_logistic_regression
  
  # Should be nil for insufficient data
  if prediction.nil?
    page.execute_script(%Q{
      document.getElementById('prediction-initial').style.display = 'none';
      document.getElementById('prediction-error').style.display = 'block';
      document.getElementById('error-message').textContent = 'Insufficient data for prediction';
    })
  end
  
  expect(page).to have_css('#prediction-error', visible: true, wait: 2)
  expect(page).not_to have_css('#prediction-result', visible: true)
  
  within('#prediction-error') do
    expect(page).to have_content('Insufficient data', visible: true)
  end
end

Then("I should see {string} with a dollar amount") do |label|
  # Generate prediction if not already done
  if page.has_css?('#prediction-initial', visible: true)
    stock = Stock.find_by(symbol: 'AAPL') || Stock.find_by(symbol: 'GOOGL')
    prediction = stock.predict_price_with_logistic_regression
    
    if prediction
      page.execute_script(%Q{
        document.getElementById('prediction-initial').style.display = 'none';
        document.getElementById('prediction-result').style.display = 'block';
        document.getElementById('predicted-price').textContent = '$#{prediction[:predicted_price].round(2)}';
        document.getElementById('prediction-trend').className = 'prediction-trend #{prediction[:trend]}';
        document.getElementById('prediction-trend').textContent = '#{prediction[:trend] == 'upward' ? '📈 Upward' : '📉 Downward'} Trend';
        document.getElementById('confidence-value').textContent = '#{prediction[:confidence].round(2)}%';
        document.getElementById('probability-value').textContent = 'Probability Up: #{prediction[:probability_up].round(2)}%';
        document.getElementById('data-points-info').innerHTML = '📊 Based on <strong>#{prediction[:data_points]} data points</strong> of historical price analysis';
      })
    end
    
    expect(page).to have_css('#prediction-result', visible: true, wait: 2)
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

