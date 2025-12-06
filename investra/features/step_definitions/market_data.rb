  Given('the following stocks exist:') do |table|
    table.hashes.each do |row|
      Stock.create!(ticker: row['ticker'], company_name: row['company_name'], sector: row['sector'], nasdaq: row['nasdaq'])
    end
  end
  
  Given('the current time is {string}') do |string|
    Timecop.freeze(Time.parse(string))
  end
  
  Given('I am a signed-in user') do
    @user = User.create!(
      email: 'test@example.com', 
      password: 'password',
      first_name: 'Test',
      last_name: 'User'
    )
    visit login_path
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'
  end
  
  Given('there are price points for {string} covering the last year, month, and week') do |string|
    stock = Stock.find_by(ticker: string)
    PricePoint.create!(stock: stock, price: rand(100..200), recorded_at: Time.now - 365.days)
    PricePoint.create!(stock: stock, price: rand(100..200), recorded_at: Time.now - 30.days)
    PricePoint.create!(stock: stock, price: rand(100..200), recorded_at: Time.now - 7.days)
  end
  
  Given('there are three recent news for {string}') do |string|
    stock = Stock.find_by(ticker: string)
    3.times do |i|
      News.create!(stock: stock, title: "News #{i+1}", place_published: "Source #{i+1}", url: "http://example.com/#{i+1}", published_time: Time.now - i.days)
    end
  end
  
  Given('there is a prediction for {string} with horizon {string}') do |string, string2|
    stock = Stock.find_by(ticker: string)
    Prediction.create!(stock: stock, horizon: string2, summary: "Predicted price will rise.", predicted_price: rand(100..200), generated_at: Time.now, confidence: rand(0.1..0.9), model_used: "Finn4")
  end
  
  When('I visit the stock detail page for {string}') do |string|
    stock = Stock.find_by(ticker: string)
    visit stock_path(stock)
  end
  
  Then('I should see the title {string}') do |string|
    expect(page).to have_content(string)
  end
  
  Then('I should see a current price') do
    expect(page).to have_content(/\$?\d+/)
  end
  
  Then('I should see a price trend graph') do
    expect(page).to have_css('#price-graph')
  end
  
  Then('I should see controls labeled {string}, {string}, {string}, {string}') do |string, string2, string3, string4|
    expect(page).to have_button(string)
    expect(page).to have_button(string2)
    expect(page).to have_button(string3)
    expect(page).to have_button(string4)
  end
  
  Then('I should see the prediction summary') do
    expect(page).to have_content("Prediction Summary")
  end
  
  Then('I should see the recent news list with {int} items') do |int|
  # Then('I should see the recent news list with {float} items') do |float|
    expect(page).to have_css('.news-item', count: int)
  end
  
  Given('I am viewing the stock detail page for {string}') do |string|
    stock = Stock.find_by(ticker: string)
    visit stock_path(stock)
  end
  
  Then('I should see the price trend graph showing the last {int} days') do |int|
    expect(page).to have_content("Last #{int} days")
  end
  
  When('I click the {string} button') do |string|
    click_button(string)
  end
  
  Given('there are price points for {string} at {string} and {string}') do |string, string2, string3|
    stock = Stock.find_by(ticker: string)
    PricePoint.create!(stock: stock, price: rand(100..200), recorded_at: Time.parse(string2))
    PricePoint.create!(stock: stock, price: rand(100..200), recorded_at: Time.parse(string3))
  end
  
  Then('I should see the latest price recorded at {string}') do |string|
    expect(page).to have_content(Time.parse(time_str).strftime('%H:%M:%S'))
  end
  
  When('a new price point for {string} is created at {string}') do |string, string2|
    stock = Stock.find_by(ticker: string)
    PricePoint.create!(stock: stock, price: rand(100..200), recorded_at: Time.parse(string2))
  end
  
  When('I refresh the page') do
    visit current_path
  end
  
  Given('there is no prediction for {string}') do |string|
    stock = Stock.find_by(ticker: string)
    Prediction.where(stock: stock).destroy_all
  end
  
  Then('I should see {string} within the prediction section') do |string|
    within('#prediction-section') do
      expect(page).to have_content(string)
    end
  end
  
  Given('the news feed is empty for {string}') do |string|
    stock = Stock.find_by(ticker: string)
    News.where(stock: stock).destroy_all
  end
  
  # Removed duplicate step - now in common_steps.rb
  
  Given('a new stock {string} exists with ticker {string}') do |string, string2|
    Stock.create!(ticker: string2, company_name: string, sector: "Technology")
  end
  
  Given('there are no price points for {string}') do |string|
    stock = Stock.find_by(ticker: string)
    PricePoint.where(stock: stock).destroy_all
  end
  
  Then('I should see an empty price trend graph') do
    expect(page).to have_css('#price-graph', visible: false)
  end